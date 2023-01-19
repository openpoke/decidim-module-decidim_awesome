# frozen_string_literal: true

require "spec_helper"

describe "Admin accountability", type: :system do
  let(:organization) { create :organization }
  let!(:admin) { create :user, :admin, :confirmed, organization: organization }

  let(:administrator) { create(:user, organization: organization) }
  let(:valuator) { create(:user, organization: organization) }
  let(:collaborator) { create(:user, organization: organization) }
  let(:moderator) { create(:user, organization: organization) }
  let(:participatory_process) { create(:participatory_process, organization: organization) }

  let(:status) { true }

  before do
    allow(Decidim::DecidimAwesome.config).to receive(:allow_admin_accountability).and_return(status)
    switch_to_host(organization.host)
    login_as admin, scope: :user

    visit decidim_admin.root_path
  end

  context "when admin accountability is enabled" do
    it "shows the admin accountability link" do
      click_link "Participants"

      expect(page).to have_content("Admin accountability")
    end
  end

  context "when admin accountability is disabled" do
    let(:status) { :disabled }

    it "does not show the admin accountability link" do
      click_link "Participants"

      expect(page).not_to have_content("Admin accountability")
    end
  end

  describe "admin action list" do
    context "when there are no admin actions" do
      before do
        create(:participatory_process_user_role, user: administrator, participatory_process: participatory_process, role: "admin", created_at: Time.current - 1.day)
        create(:participatory_process_user_role, user: valuator, participatory_process: participatory_process, role: "valuator", created_at: Time.current - 1.day)
        create(:participatory_process_user_role, user: collaborator, participatory_process: participatory_process, role: "collaborator", created_at: Time.current - 1.day)
        create(:participatory_process_user_role, user: moderator, participatory_process: participatory_process, role: "moderator", created_at: Time.current - 1.day)

        click_link "Participants"
        click_link "Admin accountability"
      end

      it "shows the correct roles for each user", versioning: true do
        expect(page).to have_content("administrator", count: 1)
        expect(page).to have_content("valuator", count: 1)
        expect(page).to have_content("collaborator", count: 1)
        expect(page).to have_content("moderator", count: 1)
      end
    end
  end
end
