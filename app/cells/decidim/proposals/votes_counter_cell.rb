# frozen_string_literal: true

module Decidim
  module Proposals
    class VotesCounterCell < Decidim::ViewModel
      include Decidim::IconHelper

      def show
        render :show
      end

      def green_votes
        content_tag :span, "G:#{model.weight_count(1)}", class: "text-success"
      end

      def yellow_votes
        content_tag :span, "Y:#{model.weight_count(2)}", class: "text-warning"
      end

      def red_votes
        content_tag :span, "R:#{model.weight_count(3)}", class: "text-alert"
      end

      def current_vote
        @current_vote ||= Decidim::Proposals::ProposalVote.find_by(author: current_user, proposal: model)
      end

      def user_voted_weight
        current_vote&.weight
      end

      def vote_btn_class
        case user_voted_weight
        when 1
          "success"
        when 2
          "warning"
        when 3
          "danger"
        else
          "hollow"
        end
      end
    end
  end
end
