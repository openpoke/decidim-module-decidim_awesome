# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Proposals
      module ProposalVotesControllerOverride
        extend ActiveSupport::Concern
        include Decidim::DecidimAwesome::AwesomeHelpers

        included do
          before_action :validate_weight, only: [:create]
          after_action :update_weight, only: [:create]

          private

          def validate_weight
            return unless vote_manifest
            return if vote_manifest.valid_weight? weight, user: current_user, proposal: proposal

            render json: { error: I18n.t("proposal_votes.create.error", scope: "decidim.proposals") }, status: :unprocessable_entity
          end

          def update_weight
            return unless response.status == 200
            return unless vote_manifest
            return unless current_vote

            current_vote.weight = weight
          end

          def current_vote
            @current_vote ||= Decidim::Proposals::ProposalVote.find_by(author: current_user, proposal: proposal)
          end

          def vote_manifest
            @vote_manifest ||= awesome_voting_for_component?(component_settings)
          end

          def weight
            params[:weight].to_i
          end
        end
      end
    end
  end
end
