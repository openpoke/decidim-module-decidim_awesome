# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module HasVoteWeight
      extend ActiveSupport::Concern

      included do
        has_one :vote_weight, foreign_key: "proposal_vote_id", class_name: "Decidim::DecidimAwesome::VoteWeight", dependent: :destroy

        def weight=(weight)
          vote_weight ||= build_vote_weight
          if vote_weight.weight != weight
            vote_weight.weight = weight
            vote_weight.save
          end
        end

        def weight
          vote_weight&.weight
        end
      end
    end
  end
end
