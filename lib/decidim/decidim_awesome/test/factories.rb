# frozen_string_literal: true

require "decidim/core/test/factories"
require "decidim/proposals/test/factories"
require "decidim/surveys/test/factories"

FactoryBot.define do
  factory :awesome_config, class: "Decidim::DecidimAwesome::AwesomeConfig" do
    var { Faker::Hacker.noun }
    value { Decidim::DecidimAwesome.config.to_a.sample(1).to_h }
    organization { create :organization }
  end

  factory :config_constraint, class: "Decidim::DecidimAwesome::ConfigConstraint" do
    settings { { Faker::Hacker.noun => Faker::Hacker.noun } }
    awesome_config { create :awesome_config }
  end

  factory :awesome_editor_image, class: "Decidim::DecidimAwesome::EditorImage" do
    file { Decidim::Dev.test_file("city.jpeg", "image/jpeg") }
    path { Faker::Internet.url(host: "", scheme: "") }
    author { create :user }
    organization { create :organization }
  end

  factory :paper_trail_version, class: Decidim::DecidimAwesome::PaperTrailVersion do
    item_id { user.id }
    item_type { "Decidim::ParticipatoryProcessUserRole" }
    event { "create" }
    created_at { 1.hour.ago }
  end

  factory :map_component, parent: :component do
    name { Decidim::Components::Namer.new(participatory_space.organization.available_locales, :proposals).i18n_name }
    manifest_name { :awesome_map }
    participatory_space { create(:participatory_process, :with_steps, organization: organization) }
  end

  factory :iframe_component, parent: :component do
    name { Decidim::Components::Namer.new(participatory_space.organization.available_locales, :proposals).i18n_name }
    manifest_name { :awesome_iframe }
    participatory_space { create(:participatory_process, :with_steps, organization: organization) }
  end

  factory :awesome_vote_weight, class: "Decidim::DecidimAwesome::VoteWeight" do
    vote { create :proposal_vote }
    sequence(:weight) { |n| n }
  end

  factory :awesome_weight_cache, class: "Decidim::DecidimAwesome::WeightCache" do
    proposal { create :proposal }

    trait :with_votes do
      after :create do |weight|
        5.times.collect do |n|
          vote = create(:proposal_vote, proposal: weight.proposal, author: create(:user, organization: weight.proposal.organization))
          create(:awesome_vote_weight, vote: vote, weight: n + 1)
        end
      end
    end
  end
end
