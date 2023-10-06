# frozen_string_literal: true

class CreateDecidimAwesomeVoteWeights < ActiveRecord::Migration[6.0]
  def change
    create_table :decidim_awesome_vote_weights do |t|
      # this might be polymorphic in the future (if other types of votes are supported)
      t.references :proposal_vote, null: false, index: { name: "decidim_awesome_proposals_weights_vote" }

      t.jsonb :weights
      t.timestamps
    end
  end
end