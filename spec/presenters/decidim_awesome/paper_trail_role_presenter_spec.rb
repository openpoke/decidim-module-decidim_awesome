# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
  describe PaperTrailRolePresenter, type: :helper do
    include Rails.application.routes.url_helpers

    let(:organization) { create :organization }
    let(:user) { Decidim::User.create(name: "test_user", email: "test@example.com", organization: organization) }
    let(:participatory_process) { create(:participatory_process, organization: organization) }
    let(:participatory_process_user_role) { create(:participatory_process_user_role, role: "admin", participatory_process: participatory_process, user: user) }
    let(:create_entry) { PaperTrail::Version.create(item: participatory_process_user_role, event: "create", item_type: "Decidim::ParticipatoryProcessUserRole") }
    let(:destroy_entry) { PaperTrail::Version.create(item: participatory_process_user_role, event: "destroy", item_type: "Decidim::ParticipatoryProcessUserRole") }
    let(:presenter) { described_class.new(entry) }

    before do
      helper.class.include Decidim::TranslatableAttributes
      create_entry.update(created_at: 1.week.ago)
      destroy_entry.update(created_at: Time.current)
    end

    describe "#role" do
      context "when the entry is a create event" do
        let(:entry) { create_entry }

        it "returns the role of the user" do
          expect(presenter.role).to eq("administrator")
        end
      end

      context "when the entry is a destroy event" do
        let(:entry) { destroy_entry }

        it "returns the role of the user before being destroyed" do
          expect(presenter.role).to eq("administrator")
        end
      end
    end

    describe "#participatory_process" do
      context "when the entry is a create event" do
        let(:entry) { create_entry }

        it "returns the participatory space of the user role" do
          expect(presenter.participatory_space).to eq(participatory_process)
        end
      end

      context "when the entry is a destroy event" do
        let(:entry) { destroy_entry }

        it "returns the participatory space of the user role before being destroyed" do
          expect(presenter.participatory_space).to eq(participatory_process)
        end
      end
    end
  end
end
