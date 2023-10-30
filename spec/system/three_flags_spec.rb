# frozen_string_literal: true

require "spec_helper"

describe "Three flags", type: :system do
  include_context "with a component"
  let!(:organization) { create :organization }
  let(:manifest) { :three_flags }
  let!(:component) do
    create :proposal_component, :with_votes_enabled, organization: organization, settings: {
      awesome_voting_manifest: manifest,
      three_flags_show_abstain: abstain,
      three_flags_box_title: box_title,
      three_flags_instructions: instructions,
      three_flags_show_modal_help: modal_help
    }
  end
  let!(:proposals) { create_list(:proposal, 3, component: component) }
  let!(:proposal) { Decidim::Proposals::Proposal.find_by(component: component) }
  let(:proposal_title) { translated(proposal.title) }
  let(:user) { create :user, :confirmed, organization: organization }
  let(:abstain) { true }
  let(:box_title) { nil }
  let(:instructions) { nil }
  let(:modal_help) { true }
  let!(:vote_weights) { nil }

  before do
    switch_to_host(organization.host)
  end

  context "when the user is logged in" do
    before do
      login_as user, scope: :user
      visit_component
      within "#proposal-#{proposal.id}-vote-button" do
        click_link "Click to vote"
      end
    end

    it "has correct copies" do
      expect(page).to have_content("Vote on this proposal")
      expect(page).to have_content("ABSTAIN")
      expect(page).to have_content("Green")
      expect(page).to have_content("Red")
      expect(page).to have_content("Yellow")
      expect(page).not_to have_content("Change my vote")
      expect(page).to have_selector(".vote-count[data-weight=\"1\"]", text: "0")
      expect(page).to have_selector(".vote-count[data-weight=\"2\"]", text: "0")
      expect(page).to have_selector(".vote-count[data-weight=\"3\"]", text: "0")

      click_link "Abstain"
      within ".vote_proposal_modal" do
        expect(page).to have_content('My vote is "Abstain"')
        expect(page).to have_content("Please read the election rules carefully to understand how your vote will be used by #{organization.name}")
        click_button "Cancel"
      end
      %w(Green Yellow Red).each do |color|
        within ".button--vote-button" do
          click_link color
        end
        within ".vote_proposal_modal" do
          expect(page).to have_content("My vote is \"#{color}\"")
          click_button "Cancel"
        end
      end
    end

    shared_examples "can vote" do |color, weight|
      it "votes with modal" do
        expect(page).to have_selector(".vote-count[data-weight=\"#{weight}\"]", text: "0") if weight != "0"
        within ".button--vote-button" do
          click_link color
        end
        within ".vote_proposal_modal" do
          click_button "Proceed"
        end
        %w(0 1 2 3).each do |w|
          expect(page).to have_selector(".vote-action.weight_#{w}.non-clickable")
          if w == weight
            expect(page).to have_selector(".vote-count[data-weight=\"#{w}\"]", text: "1") if w != "0"
            expect(page).not_to have_selector(".vote-action.weight_#{w}.dim")
          else
            expect(page).to have_selector(".vote-count[data-weight=\"#{w}\"]", text: "0") if w != "0"
            expect(page).to have_selector(".vote-action.weight_#{w}.dim")
          end
        end
        expect(page).to have_content("Change my vote")
      end
    end

    it_behaves_like "can vote", "Green", "3"
    it_behaves_like "can vote", "Yellow", "2"
    it_behaves_like "can vote", "Red", "1"
    it_behaves_like "can vote", "Abstain", "0"

    context "when no abstain" do
      let(:abstain) { false }

      it "has correct copies" do
        expect(page).not_to have_content("ABSTAIN")
        expect(page).to have_content("Green")
        expect(page).to have_content("Red")
        expect(page).to have_content("Yellow")
        expect(page).not_to have_content("Change my vote")
      end
    end

    context "when no default title" do
      let(:box_title) { "-" }

      it "has no title" do
        expect(page).not_to have_content("Vote on this proposal")
      end
    end

    context "when custom title" do
      let(:box_title) { "Custom title" }

      it "has custom title" do
        expect(page).to have_content("Custom title")
      end
    end

    context "when custom modal message" do
      let(:instructions) { "Custom instructions" }

      it "has custom modal message" do
        click_link "Red"
        within ".vote_proposal_modal" do
          expect(page).to have_content("Custom instructions")
        end
      end
    end

    context "when the proposal has votes" do
      let(:modal_help) { false }
      let!(:vote_weights) do
        [
          create_list(:awesome_vote_weight, 3, vote: create(:proposal_vote, proposal: proposal), weight: 1),
          create_list(:awesome_vote_weight, 2, vote: create(:proposal_vote, proposal: proposal), weight: 2),
          create_list(:awesome_vote_weight, 1, vote: create(:proposal_vote, proposal: proposal), weight: 3)
        ]
      end

      it "shows existing votes" do
        expect(page).to have_selector(".vote-count[data-weight=\"1\"]", text: "3")
        expect(page).to have_selector(".vote-count[data-weight=\"2\"]", text: "2")
        expect(page).to have_selector(".vote-count[data-weight=\"3\"]", text: "1")
      end

      it "updates vote counts when the user votes" do
        click_link "Green"
        expect(page).to have_selector(".vote-count[data-weight=\"3\"]", text: "2")
        click_link "Change my vote"
        click_link "Abstain"
        expect(page).to have_selector(".vote-count[data-weight=\"3\"]", text: "1")
      end
    end
  end

  context "when listing proposals" do
    before do
      login_as user, scope: :user
      visit_component
    end

    let!(:vote_weights) do
      [
        create_list(:awesome_vote_weight, 3, vote: create(:proposal_vote, proposal: proposal), weight: 1),
        create_list(:awesome_vote_weight, 2, vote: create(:proposal_vote, proposal: proposal), weight: 2),
        create_list(:awesome_vote_weight, 1, vote: create(:proposal_vote, proposal: proposal), weight: 3),
        create_list(:awesome_vote_weight, 4, vote: create(:proposal_vote, proposal: proposal), weight: 0)
      ]
    end

    it "shows the vote count" do
      within "#proposal_#{proposal.id}" do
        expect(page).to have_content("G: 1")
        expect(page).to have_content("Y: 2")
        expect(page).to have_content("R: 3")
        expect(page).to have_content("A: 4")
        expect(page).to have_link("Click to vote")
      end
    end

    context "when abstain is disabled" do
      let(:abstain) { false }

      it "shows the vote count" do
        within "#proposal_#{proposal.id}" do
          expect(page).to have_content("G: 1")
          expect(page).to have_content("Y: 2")
          expect(page).to have_content("R: 3")
          expect(page).not_to have_content("A: 4")
          expect(page).to have_link("Click to vote")
        end
      end
    end

    context "when the user has voted" do
      let!(:vote_weights) do
        [
          create_list(:awesome_vote_weight, 1, vote: create(:proposal_vote, proposal: proposal, author: user), weight: 1),
          create_list(:awesome_vote_weight, 2, vote: create(:proposal_vote, proposal: proposal), weight: 2),
          create_list(:awesome_vote_weight, 3, vote: create(:proposal_vote, proposal: proposal), weight: 3)
        ]
      end

      it "shows the vote count" do
        within "#proposal_#{proposal.id}" do
          expect(page).to have_content("G: 3")
          expect(page).to have_content("Y: 2")
          expect(page).to have_content("R: 1")
          expect(page).to have_content("A: 0")
          expect(page).to have_link("Voted")
        end
      end
    end
  end

  context "when the user is not logged in" do
    before do
      visit_component
    end

    let!(:vote_weights) do
      [
        create_list(:awesome_vote_weight, 3, vote: create(:proposal_vote, proposal: proposal), weight: 1),
        create_list(:awesome_vote_weight, 2, vote: create(:proposal_vote, proposal: proposal), weight: 2),
        create_list(:awesome_vote_weight, 1, vote: create(:proposal_vote, proposal: proposal), weight: 3),
        create_list(:awesome_vote_weight, 4, vote: create(:proposal_vote, proposal: proposal), weight: 0)
      ]
    end

    it "shows the vote count", :caching do
      within "#proposal_#{proposal.id}" do
        expect(page).to have_content("G: 1")
        expect(page).to have_content("Y: 2")
        expect(page).to have_content("R: 3")
        expect(page).to have_content("A: 4")
        expect(page).to have_link("Click to vote")
        # check the cached card by maintaining the number of votes and change the weight
        Decidim::DecidimAwesome::VoteWeight.find_by(weight: 3).update(weight: 1)
        visit_component
        expect(page).to have_content("G: 0")
        expect(page).to have_content("Y: 2")
        expect(page).to have_content("R: 4")
      end
    end

    context "when no manifest" do
      let(:manifest) { nil }

      it "has normal support button" do
        within "#proposal_#{proposal.id}" do
          expect(page).to have_content("Support")
          expect(page).not_to have_content("G:")
          expect(page).not_to have_content("Y:")
          expect(page).not_to have_content("R:")
          click_link proposal.title["en"]
        end

        within ".button--vote-button" do
          expect(page).to have_content("Support")
          expect(page).not_to have_content("Green")
          expect(page).not_to have_content("Yellow")
          expect(page).not_to have_content("Red")
        end
      end
    end

    it "show the modal window on voting" do
      within "#proposal_#{proposal.id}" do
        click_link "Click to vote"
      end
      expect(page).to have_selector("#loginModal", visible: :hidden)
      click_link "Abstain"
      expect(page).to have_selector("#loginModal", visible: :visible)
    end
  end
end
