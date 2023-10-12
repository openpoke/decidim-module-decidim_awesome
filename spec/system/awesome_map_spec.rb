# frozen_string_literal: true

require "spec_helper"

describe "Show awesome map", type: :system do
  include_context "with a component"
  let(:manifest_name) { "awesome_map" }

  let!(:proposal_component) { create(:proposal_component, :with_amendments_enabled, :with_geocoding_enabled, participatory_space: participatory_process) }
  let!(:proposal) { create(:proposal, component: proposal_component, latitude: 40, longitude: 2) }
  let(:emendation) { build(:proposal, component: proposal_component, latitude: 42, longitude: 4) }
  let!(:proposal_amendment) { create(:proposal_amendment, amendable: proposal, emendation: emendation) }
  let!(:accepted_proposal) { create(:proposal, :accepted, title: { en: "Accepted proposal" }, component: proposal_component, latitude: 40, longitude: -50) }
  let!(:evaluating_proposal) { create(:proposal, :evaluating, title: { en: "Evaluating proposal" }, component: proposal_component, latitude: 30, longitude: 45) }
  let!(:not_answered_proposal) { create(:proposal, :not_answered, title: { en: "Not answered proposal" }, component: proposal_component, latitude: 70, longitude: 6) }
  let!(:null_state_proposal) { create(:proposal, state: nil, title: { en: "Null state proposal" }, component: proposal_component, latitude: 50, longitude: 10) }
  let!(:withdrawn_proposal) { create(:proposal, :withdrawn, title: { en: "Withdrawn proposal" }, component: proposal_component, latitude: 60, longitude: -30) }
  let!(:rejected_proposal) { create(:proposal, :rejected, title: { en: "Rejected proposal" }, component: proposal_component, latitude: 10, longitude: 80) }
  let!(:category) { create(:category, participatory_space: participatory_process) }
  let!(:subcategory) { create(:subcategory, parent: category, participatory_space: participatory_process) }
  let!(:user) { create :user, :confirmed, organization: organization }
  let(:active_step_id) { component.participatory_space.active_step.id }
  let(:settings) do
    {
      menu_amendments: show_amendments,
      menu_meetings: show_meetings
    }
  end

  let(:step_settings) do
    {
      show_accepted: show_accepted,
      show_evaluating: show_evaluating,
      show_rejected: show_rejected,
      show_withdrawn: show_withdrawn,
      show_not_answered: show_not_answered
    }
  end
  let(:show_accepted) { true }
  let(:show_evaluating) { true }
  let(:show_rejected) { true }
  let(:show_withdrawn) { true }
  let(:show_not_answered) { true }

  let(:show_amendments) { true }
  let(:show_meetings) { true }
  let(:map_config) do
    {
      provider: :osm,
      # api_key: "foo",
      # static: { url: "https://image.maps.ls.hereapi.com/mia/1.6/mapview" }
      dynamic: {
        tile_layer: {
          url: "https://tile.openstreetmap.org/{z}/{x}/{y}.png?key={apiKey}&{foo}",
          api_key: true,
          foo: "bar=baz",
          attribution: %(
            <a href="https://www.openstreetmap.org/copyright" target="_blank">&copy; OpenStreetMap</a> contributors
          ).strip
          # Translatable attribution:
          # attribution: -> { I18n.t("tile_layer_attribution") }
        }
      },
      # static: { url: "https://staticmap.openstreetmap.de/staticmap.php" },
      geocoding: { host: "nominatim.openstreetmap.org", use_https: true }
    }
  end

  before do
    allow(Decidim.config).to receive(:maps).and_return(map_config)
    component.update!(step_settings: { active_step_id => step_settings })
    visit_component
  end

  it "shows the map" do
    within ".wrapper" do
      expect(page).to have_selector(".awesome-map")
      expect(page).to have_selector("#awesome-map")
      errors = if legacy_version?
                 page.driver.browser.manage.logs.get(:browser)
               else
                 page.driver.browser.logs.get(:browser)
               end

      errors.each do |error|
        expect(error.message).not_to include("map.js"), error.message if error.level == "SEVERE"
      end
    end
  end

  it "has AwesomeMap javascript and CSS" do
    within "head", visible: :all do
      expect(page).to have_xpath("//link[@rel='stylesheet'][contains(@href,'decidim_decidim_awesome_map')]", visible: :all)
      expect(page).to have_xpath("//link[@rel='stylesheet'][contains(@href,'decidim_map')]", visible: :all)
    end
    within(legacy_version? ? "head" : ".wrapper", visible: :all) do
      expect(page).to have_xpath("//script[contains(@src,'decidim_decidim_awesome_map')]", visible: :all)
      expect(page).to have_xpath("//script[contains(@src,'decidim_map')]", visible: :all)
    end
  end

  it "shows categories and colors" do
    within ".awesome-map" do
      expect(page.body).to have_content(".awesome_map-category_#{category.id}")
      expect(page.body).to have_content(".awesome_map-category_#{subcategory.id}")
    end
  end

  context "when step settings are all true" do
    it "shows all proposals markers" do
      sleep(5)
      expect(page.body).to have_selector("div[title='#{accepted_proposal.title["en"]}']")
      expect(page.body).to have_selector("div[title='#{evaluating_proposal.title["en"]}']")
      expect(page.body).to have_selector("div[title='#{rejected_proposal.title["en"]}']")
      expect(page.body).to have_selector("div[title='#{withdrawn_proposal.title["en"]}']")
      expect(page.body).to have_selector("div[title='#{null_state_proposal.title["en"]}']")
    end
  end

  context "when step settings are all false" do
    let(:show_accepted) { false }
    let(:show_evaluating) { false }
    let(:show_rejected) { false }
    let(:show_withdrawn) { false }
    let(:show_not_answered) { false }

    it "does not show any proposal" do
      sleep(1)
      expect(page.body).not_to have_selector("div[title='#{accepted_proposal.title["en"]}']")
      expect(page.body).not_to have_selector("div[title='#{evaluating_proposal.title["en"]}']")
      expect(page.body).not_to have_selector("div[title='#{rejected_proposal.title["en"]}']")
      expect(page.body).not_to have_selector("div[title='#{withdrawn_proposal.title["en"]}']")
      expect(page.body).not_to have_selector("div[title='#{null_state_proposal.title["en"]}']")
    end
  end

  context "when only the not answered option is enabled" do
    let(:show_accepted) { false }
    let(:show_evaluating) { false }
    let(:show_rejected) { false }
    let(:show_withdrawn) { false }
    let(:show_not_answered) { true }

    it "only shows proposal without state" do
      sleep(1)
      expect(page.body).not_to have_selector("div[title='#{accepted_proposal.title["en"]}']")
      expect(page.body).not_to have_selector("div[title='#{evaluating_proposal.title["en"]}']")
      expect(page.body).not_to have_selector("div[title='#{rejected_proposal.title["en"]}']")
      expect(page.body).not_to have_selector("div[title='#{withdrawn_proposal.title["en"]}']")
      expect(page.body).to have_selector("div[title='#{null_state_proposal.title["en"]}']")
    end
  end

  # TODO: figure out a way to test leaflet without any map provider
  # it "shows the proposal component as a menu" do
  #   expect(page.body).to have_content(".awesome_map-component_#{component.id}")
  # end

  # it "shows amendments as a menu" do
  #   expect(page.body).to have_content(".awesome_map-amendments_#{component.id}")
  # end

  # context "when hiding admendments" do
  #   let(:show_amendments) { false }

  #   it "do not show the admendments menu item" do
  #   end
  # end

  # context "when hiding meetings" do
  #   let(:show_meetings) { true }

  #   it "do not show the meetings menu item" do
  #   end
  # end
end
