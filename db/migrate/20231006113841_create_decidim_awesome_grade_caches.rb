# frozen_string_literal: true

class CreateDecidimAwesomeGradeCaches < ActiveRecord::Migration[6.0]
  def change
    create_table :decidim_awesome_grade_caches do |t|
      # this might be polymorphic in the future (if other types of votes are supported)
      t.references :decidim_proposal, null: false, index: { name: "decidim_awesome_proposals_grades_cache" }

      t.integer :grade, null: false, default: 1
      t.timestamps
    end
  end
end
