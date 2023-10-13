# frozen_string_literal: true

module Decidim
  module Proposals
    class VotesCounterCell < Decidim::ViewModel
      def show
        render :show
      end

      def green_votes
        content_tag :span, "G:#{model.weight_count(1)}", class: 'text-success'
      end

      def yellow_votes
        content_tag :span, "Y:#{model.weight_count(2)}", class: 'text-warning'
      end

      def red_votes
        content_tag :span, "R:#{model.weight_count(3)}", class: 'text-alert'
      end
    end
  end
end
