# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Proposals
      module ProposalVotesControllerOverride
        extend ActiveSupport::Concern
        include Decidim::DecidimAwesome::AwesomeHelpers

        included do
          # rubocop:disable Rails/LexicallyScopedActionFilter
          before_action :validate_weight, only: :create
          # rubocop:enable Rails/LexicallyScopedActionFilter

          def create
            enforce_permission_to :vote, :proposal, proposal: proposal
            @from_proposals_list = params[:from_proposals_list] == "true"

            Decidim::Proposals::VoteProposal.call(proposal, current_user) do
              on(:ok) do
                current_vote.weight = weight if current_vote && vote_manifest

                proposal.reload

                proposals = Decidim::Proposals::ProposalVote.where(
                  author: current_user,
                  proposal: Decidim::Proposals::Proposal.where(component: current_component)
                ).map(&:proposal)

                expose(proposals: proposals)
                render :update_buttons_and_counters
                broadcast_vote_update
              end

              on(:invalid) do
                render json: { error: I18n.t("proposal_votes.create.error", scope: "decidim.proposals") }, status: :unprocessable_entity
              end
            end
          end

          def destroy
            enforce_permission_to :unvote, :proposal, proposal: proposal
            @from_proposals_list = params[:from_proposals_list] == "true"

            Decidim::Proposals::UnvoteProposal.call(proposal, current_user) do
              on(:ok) do
                proposal.reload

                proposals = Decidim::Proposals::ProposalVote.where(
                  author: current_user,
                  proposal: Decidim::Proposals::Proposal.where(component: current_component)
                ).map(&:proposal)

                expose(proposals: proposals + [proposal])
                render :update_buttons_and_counters
              end
            end

            broadcast_vote_update
          end

          private

          def validate_weight
            return true if weight == 0
            return unless vote_manifest
            return if vote_manifest.valid_weight? weight, user: current_user, proposal: proposal

            render json: { error: I18n.t("proposal_votes.create.error", scope: "decidim.proposals") }, status: :unprocessable_entity
          end

          def current_vote
            @current_vote ||= Decidim::Proposals::ProposalVote.find_by(author: current_user, proposal: proposal)
          end

          def vote_manifest
            @vote_manifest ||= awesome_voting_manifest_for(current_component)
          end

          def weight
            params.dig(:weight, :weight).to_i
          end

          def broadcast_vote_update
            vote_counts = (1..3).each_with_object({}) do |i, hash|
              hash["vote_count_#{i}"] = proposal.weight_count(i)
            end

            payload = {
              proposal_id: proposal.id,
              user_voted_weight: current_vote&.weight
            }.merge(vote_counts)

            ActionCable.server.broadcast("proposal_vote_#{proposal.id}_channel", payload, coder: ActiveSupport::JSON)
          end
        end
      end
    end
  end
end
