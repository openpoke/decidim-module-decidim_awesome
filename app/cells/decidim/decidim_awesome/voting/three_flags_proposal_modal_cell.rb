# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Voting
      class ThreeFlagsProposalModalCell < Decidim::ViewModel
        include Decidim::ComponentPathHelper
        include Decidim::Proposals::Engine.routes.url_helpers
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

        def vote_instructions
          translated_attribute(current_component.settings.proposal_vote_instructions)
        end

        def proposal_vote_path(weight)
          proposal_proposal_vote_path(proposal_id: proposal.id, from_proposals_list: from_proposals_list, weight: weight)
        end

        def weight
          options[:weight].to_i
        end
      end
    end
  end
end
