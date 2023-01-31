# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
  describe PaperTrailRolePresenter, type: :helper do
    let(:user) { create :user, organization: organization }
    let(:organization) { create :organization }
    let(:participatory_space) { create(:participatory_process, organization: organization) }
    let(:role) { "admin" }
    let(:participatory_process_user_role) { create(:participatory_process_user_role, role: role, participatory_process: participatory_space, user: user) }
    let(:created_at) { Time.current }
    let(:entry) do
      create(:paper_trail_version, item: participatory_process_user_role,
                                   created_at: 1.week.ago,
                                   event: "create",
                                   object_changes: { "decidim_user_id" => [nil, user.id], "decidim_participatory_process_id" => [nil, participatory_space.id], "role" => [nil, role] },
                                   item_type: "Decidim::ParticipatoryProcessUserRole")
    end

    let(:destroy_entry) do
      create(:paper_trail_version, item: participatory_process_user_role,
                                   created_at: Time.current,
                                   event: "destroy",
                                   object_changes: { "decidim_user_id" => [user.id, nil], "decidim_participatory_process_id" => [participatory_space.id, nil], "role" => [role, nil] },
                                   item_type: "Decidim::ParticipatoryProcessUserRole")
    end

    let(:action_log) { create(:action_log, organization: organization, resource_id: entry.reload.changeset["decidim_user_id"].last, action: "create") }


    subject { described_class.new(entry) }

    describe "#role" do
      it "returns the role" do
        expect(subject.role).to eq("Administrator")
      end
    end

    describe "#removal_date" do
      context "when the role was removed" do
        subject { described_class.new(destroy_entry) }

        it "returns the removal date" do
          expect(subject.removal_date).to eq(destroy_entry.created_at.strftime("%d/%m/%Y %H:%M"))
        end
      end

      context "when the role is still active" do
        it "returns currently active" do
          expect(subject.removal_date).to eq("Currently active")
        end
      end
    end

    describe "#participatory_space_name" do
      it "returns the participatory space name" do
        expect(subject.participatory_space_name).to include("Decidim::ParticipatoryProcess")
      end
    end

    describe "#participatory_space_type" do
      it "returns the participatory space type" do
        expect(subject.participatory_space_type).to eq("Decidim::ParticipatoryProcess")
      end
    end

    describe "#user_roles_path" do
      it "returns the path to user roles" do
        expect(subject.user_roles_path).to eq("/admin/participatory_processes/#{participatory_space.slug}/user_roles")
      end
    end

    describe "#user" do
      it "returns the user" do
        expect(subject.user).to eq(user)
      end
    end
  end
end
