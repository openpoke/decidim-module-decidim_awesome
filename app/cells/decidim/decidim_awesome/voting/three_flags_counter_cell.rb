# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Voting
      class ThreeFlagsCounterCell < Decidim::ViewModel
        include Decidim::IconHelper

        COLORS = { 1 => "success", 2 => "warning", 3 => "alert" }.freeze
        BUTTON_CLASSES = { 0 => "hollow", 1 => "success", 2 => "warning", 3 => "danger" }.freeze

        def show
          render :show
        end

        def resource_path
          resource_locator(model).path
        end

        def vote_span(weight, color)
          content_tag :span, "#{color[0].upcase}:#{model.weight_count(weight)}", class: "text-#{color}"
        end

        def green_votes
          vote_span(1, "green")
        end

        def yellow_votes
          vote_span(2, "yellow")
        end

        def red_votes
          vote_span(3, "red")
        end

        def current_vote
          @current_vote ||= Decidim::Proposals::ProposalVote.find_by(author: current_user, proposal: model)
        end

        def user_voted_weight
          current_vote&.weight
        end

        def vote_btn_class
          BUTTON_CLASSES[user_voted_weight.to_i]
        end
      end
    end
  end
end
