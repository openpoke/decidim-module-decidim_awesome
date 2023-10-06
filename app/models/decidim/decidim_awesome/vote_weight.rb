# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    class VoteWeight < ApplicationRecord
      self.table_name = "decidim_awesome_vote_weights"
      belongs_to :vote, foreign_key: "proposal_vote_id", class_name: "Decidim::Proposals::ProposalVote"

      delegate :proposal, to: :vote

      after_save :update_vote_weight_totals

      def update_vote_weight_totals
        cache = proposal&.weight_cache || Decidim::DecidimAwesome::WeightCache.new(proposal: proposal)
        cache.totals = cache.totals || {}

        cache.totals[weight] = Decidim::DecidimAwesome::VoteWeight.where(vote: proposal.votes, weight: weight).count
        cache.save
      end
    end
  end
end
