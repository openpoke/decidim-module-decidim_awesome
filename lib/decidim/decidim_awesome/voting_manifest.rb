# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    class VotingManifest
      include ActiveModel::Model
      # From 0.27 onwards, Virtus is deprecated
      if defined? Decidim::AttributeObject::Model
        include Decidim::AttributeObject::Model
      else
        include Virtus.model
      end

      attribute :name, Symbol

      # path to overriden views for the proposal show page vote button
      # not defining or using nil will hide the original content
      attribute :show_vote_button_view
      attribute :show_votes_count_view
      attribute :show_participatory_texts_proposal_votes_count_view
    end
  end
end
