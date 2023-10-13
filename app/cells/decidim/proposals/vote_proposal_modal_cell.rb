# frozen_string_literal: true

module Decidim
  module Proposals
    class VoteProposalModalCell < Decidim::ViewModel
      def show
        render :show
      end

      def proposal
        model
      end

      def modal_id
        options[:modal_id] || "voteProposalModal"
      end
    end
  end
end
