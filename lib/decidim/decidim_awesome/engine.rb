# frozen_string_literal: true

require "rails"
require "deface"
require "decidim/core"
require "decidim/decidim_awesome/awesome_helpers"

module Decidim
  module DecidimAwesome
    # This is the engine that runs on the public interface of decidim_awesome.
    class Engine < ::Rails::Engine
      include AwesomeHelpers

      isolate_namespace Decidim::DecidimAwesome

      routes do
        post :editor_images, to: "editor_images#create"
      end

      # Prepare a zone to create overrides
      # https://edgeguides.rubyonrails.org/engines.html#overriding-models-and-controllers
      # overrides
      config.to_prepare do
        # activate Decidim LayoutHelper for the overriden views
        ActiveSupport.on_load :action_controller do
          helper Decidim::LayoutHelper if respond_to?(:helper)
        end
        # Include additional helpers globally
        ActionView::Base.include(Decidim::DecidimAwesome::AwesomeHelpers)

        # Override EtiquetteValidator
        EtiquetteValidator.include(Decidim::DecidimAwesome::EtiquetteValidatorOverride) if DecidimAwesome.enabled?([:validate_title_max_caps_percent,
                                                                                                                    :validate_title_max_marks_together,
                                                                                                                    :validate_title_start_with_caps,
                                                                                                                    :validate_body_max_caps_percent,
                                                                                                                    :validate_body_max_marks_together,
                                                                                                                    :validate_body_start_with_caps])

        # Custom fields need to deal with several places
        if DecidimAwesome.enabled?([:proposal_custom_fields,
                                    :validate_title_min_length,
                                    :validate_title_max_caps_percent,
                                    :validate_title_max_marks_together,
                                    :validate_title_start_with_caps,
                                    :validate_body_min_length,
                                    :validate_body_max_caps_percent,
                                    :validate_body_max_marks_together,
                                    :validate_body_start_with_caps])
          Decidim::Proposals::ProposalWizardCreateStepForm.include(Decidim::DecidimAwesome::Proposals::ProposalWizardCreateStepFormOverride)
        end

        # override user's admin property
        Decidim::User.include(Decidim::DecidimAwesome::UserOverride) if DecidimAwesome.enabled?(:scoped_admins)

        if DecidimAwesome.enabled?(:weighted_proposal_voting)
          # add vote weight to proposal vote
          Decidim::Proposals::ProposalVote.include(Decidim::DecidimAwesome::HasVoteWeight)
          # add vote weight cache to proposal
          Decidim::Proposals::Proposal.include(Decidim::DecidimAwesome::HasWeightCache)
        end

        Decidim::MenuPresenter.include(Decidim::DecidimAwesome::MenuPresenterOverride)
        Decidim::MenuItemPresenter.include(Decidim::DecidimAwesome::MenuItemPresenterOverride)

        # Late registering of components to take into account initializer values
        DecidimAwesome.registered_components.each do |manifest, block|
          next if DecidimAwesome.disabled_components.include?(manifest)
          next if Decidim.find_component_manifest(manifest)

          Decidim.register_component(manifest, &block)
        end
      end

      initializer "decidim_decidim_awesome.overrides", after: "decidim.action_controller" do
        config.to_prepare do
          # redirect unauthorized scoped admins to allowed places or custom redirects if configured
          Decidim::ErrorsController.include(Decidim::DecidimAwesome::NotFoundRedirect) if DecidimAwesome.enabled?([:scoped_admins, :custom_redirects])

          # Custom fields need to deal with several places
          if DecidimAwesome.enabled?(:proposal_custom_fields)
            Decidim::Proposals::ApplicationHelper.include(Decidim::DecidimAwesome::Proposals::ApplicationHelperOverride)
            Decidim::AmendmentsHelper.include(Decidim::DecidimAwesome::AmendmentsHelperOverride)
          end
        end
      end

      initializer "decidim_decidim_awesome.middleware" do |app|
        app.config.middleware.insert_after Decidim::Middleware::CurrentOrganization, Decidim::DecidimAwesome::CurrentConfig
      end

      initializer "decidim_decidim_awesome.weighted_proposal_voting" do |_app|
        if DecidimAwesome.enabled?(:weighted_proposal_voting)
          # register available processors
          Decidim::DecidimAwesome.voting_registry.register(:three_flags) do |voting|
            voting.show_vote_button_view = "decidim/decidim_awesome/voting/three_flags/show_vote_button"
            # voting. "Decidim::DecidimAwesome::Voting::ThreeFlags"
          end
        end
      end

      initializer "decidim_decidim_awesome.webpacker.assets_path" do
        Decidim.register_assets_path File.expand_path("app/packs", root)
      end

      initializer "decidim_decidim_awesome.add_cells_view_paths" do
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::DecidimAwesome::Engine.root}/app/cells")
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::DecidimAwesome::Engine.root}/app/views")
      end
    end
  end
end
