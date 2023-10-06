# frozen_string_literal: true

class CreateDecidimAwesomeVoteGrades < ActiveRecord::Migration[6.0]
  def change
    create_table :decidim_awesome_vote_grades do |t|
      # this might be polymorphic in the future (if other types of votes are supported)
      t.references :proposal_vote, null: false, index: { name: "decidim_awesome_proposals_grades_vote" }

      t.jsonb :grades
      t.timestamps
    end
  end
end
