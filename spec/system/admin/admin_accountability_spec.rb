# frozen_string_literal: true

require "spec_helper"

describe "Admin accountability", type: :system do
  let(:user_creation_date) { 5.days.ago }
  let(:creation_date) { 3.days.ago }
  let(:login_date) { 2.days.ago }
  let(:organization) { create :organization }
  let!(:admin) { create :user, :admin, :confirmed, organization: organization }

  let(:administrator) { create(:user, organization: organization, last_sign_in_at: login_date, created_at: user_creation_date) }
  let(:valuator) { create(:user, organization: organization, created_at: user_creation_date) }
  let(:collaborator) { create(:user, organization: organization, created_at: user_creation_date) }
  let(:moderator) { create(:user, organization: organization, created_at: user_creation_date) }
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
    context "when there are admin actions" do
      before do
        create(:participatory_process_user_role, user: administrator, participatory_process: participatory_process, role: "admin", created_at: creation_date)
        create(:participatory_process_user_role, user: valuator, participatory_process: participatory_process, role: "valuator", created_at: creation_date)
        create(:participatory_process_user_role, user: collaborator, participatory_process: participatory_process, role: "collaborator", created_at: creation_date)
        create(:participatory_process_user_role, user: moderator, participatory_process: participatory_process, role: "moderator", created_at: creation_date)

        user_to_delete = Decidim::ParticipatoryProcessUserRole.find_by(user: collaborator)
        user_to_delete.destroy

        click_link "Participants"
        click_link "Admin accountability"
      end

      it "shows the correct information for each user", versioning: true do
        expect(page).to have_content("Administrator", count: 1)
        expect(page).to have_content("Valuator", count: 1)
        expect(page).to have_content("Collaborator", count: 1)
        expect(page).to have_content("Moderator", count: 1)

        expect(page).to have_content(administrator.name, count: 1)
        expect(page).to have_content(valuator.name, count: 1)
        expect(page).to have_content(collaborator.name, count: 1)
        expect(page).to have_content(moderator.name, count: 1)

        expect(page).to have_content(administrator.email, count: 1)
        expect(page).to have_content(valuator.email, count: 1)
        expect(page).to have_content(collaborator.email, count: 1)
        expect(page).to have_content(moderator.email, count: 1)
      end

      it "shows dates", versioning: true do
        expect(page).to have_css("table tr td:nth-child(6)", text: creation_date.strftime("%d/%m/%Y %H:%M"), count: 4)
      end

      context "when the user was logged in" do
        it "shows the last login date", versioning: true do
          expect(page).to have_css("table tr td:nth-child(5)", text: login_date.strftime("%d/%m/%Y %H:%M"), count: 1)
        end
      end

      context "when the user was deleted" do
        it "shows the user as deleted", versioning: true do
          expect(page).to have_content("Currently active", count: 3)
          expect(page).to have_css("table tr td:nth-child(7)", text: Time.current.strftime("%d/%m/%Y %H:%M"), count: 1)
        end
      end
    end
  end
end
