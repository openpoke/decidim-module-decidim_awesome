# frozen_string_literal: true

require "spec_helper"

describe "Admin accountability", type: :system do
  let(:organization) { create :organization }
  let!(:user) { create :user, :admin, :confirmed, organization: organization }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user

    visit decidim_admin.root_path
    click_link "Participants"
  end

  context "when admin goes to 'Participants' page" do
    it "shows 'Admin accountability' submenu" do
      expect(page).to have_link("Admin accountability")
    end
  end

  context "when admin clicks on 'Admin accountability' submenu" do
    it "has title page" do
      click_link "Admin accountability"
      expect(page).to have_css("h2", class: "card-title", text: "Admin accountability")
    end
  end
end
