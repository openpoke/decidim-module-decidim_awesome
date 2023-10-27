# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Voting
      class ThreeFlagsProposalCell < ThreeFlagsBaseCell
        VOTE_WEIGHTS = [0, 1, 2, 3].freeze

        def show
          render :show
        end

        def vote_block_for(proposal, weight)
          render partial: "vote_block", locals: {
            proposal: proposal,
            weight: weight
          }
        end

        def proposal_votes(weight)
          model.weight_count(weight)
        end

        def voted_for?(option)
          current_vote&.weight == option
        end

        def from_proposals_list
          options[:from_proposals_list]
        end

        def proposal_vote_path(weight)
          proposal_proposal_vote_path(proposal_id: proposal.id, from_proposals_list: from_proposals_list, weight: weight)
        end

        def opacity_class_for(weight)
          opacity = !voted_for_any? || voted_for?(weight) ? "fully-opaque" : "semi-opaque"
          clickable = voted_for_any? ? "non-clickable" : ""

          [opacity, clickable].reject(&:empty?).join(" ")
        end

        def voted_for_any?
          VOTE_WEIGHTS.any? { |opt| voted_for?(opt) }
        end

        def title
          txt ||= translated_attribute(current_component.settings.three_flags_box_title)
          return "" if txt == "-"

          txt.presence || t("decidim.decidim_awesome.voting.three_flags.default_box_title")
        end
      end
    end
  end
end
