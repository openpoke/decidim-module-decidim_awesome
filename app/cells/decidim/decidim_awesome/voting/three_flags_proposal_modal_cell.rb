# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Voting
      class ThreeFlagsProposalModalCell < Decidim::ViewModel
        include Decidim::ComponentPathHelper
        include Decidim::Proposals::Engine.routes.url_helpers

        def show
          render :show
        end

        def proposal
          model
        end

        def modal_id
          options[:modal_id] || "voteProposalModal"
        end

        def from_proposals_list
          options[:from_proposals_list]
        end

        def current_component
          proposal.component
        end
      end
    end
  end
end
