# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module HasWeightCache
      extend ActiveSupport::Concern

      included do
        has_one :weight_cache, foreign_key: "decidim_proposal_id", class_name: "Decidim::DecidimAwesome::WeightCache", dependent: :destroy

        def weight_count(weight)
          (weight_cache && weight_cache.totals[weight.to_s]) || 0
        end

        def vote_weights
          @vote_weights ||= begin
            totals = weight_cache&.totals || {}
            totals.to_h { |weight, count| [manifest&.label_for(weight) || weight.to_s, count || 0] }
          end
        end

        def manifest
          @manifest ||= DecidimAwesome.voting_registry.find(component.settings.awesome_voting_manifest)
        end
      end
    end
  end
end
