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
      # not defining it will use the original view from Decidim
      # setting it to an empty string will hide the original content

      # original is decidim-proposals/app/views/proposals/proposals/_vote_button.html.erb
      attribute :show_vote_button_view
      # original is decidim-proposals/app/views/proposals/proposals/_votes_count.html.erb
      attribute :show_votes_count_view
      # original is decidim-proposals/app/cells/proposals/proposal_m/footer.erb
      attribute :proposal_m_cell_footer
    end
  end
end
