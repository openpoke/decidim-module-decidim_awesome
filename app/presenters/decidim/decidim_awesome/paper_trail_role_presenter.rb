# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    class PaperTrailRolePresenter < Decidim::Log::BasePresenter
      include TranslatableAttributes

      delegate :created_at, to: :entry

      attr_reader :entry

      def initialize(entry)
        @entry = entry
      end

      def role
        role = destroy_action(entry)&.reify&.role || entry.item&.role
        role == "admin" ? "administrator" : role
      end

      def participatory_space_name
        "#{participatory_space_type} #{translated_attribute participatory_space&.title}"
      end

      def participatory_space
        entry.item&.participatory_space
      end

      def participatory_space_type
        Decidim::ActionLog.find_by(resource_id: entry.changeset["decidim_user_id"].last).try(:participatory_space_type)
      end

      def user
        Decidim::User.find_by(id: entry.changeset["decidim_user_id"].last)
      end

      def removal_date
        removal_date = destroy_action(entry)&.created_at
        removal_date ? I18n.l(removal_date, format: :short) : currently_active
      end

      def currently_active
        I18n.t("decidim.decidim_awesome.admin.admin_accountability.currently_active", default: "Currently active")
      end

      private

      def destroy_action(entry)
        PaperTrail::Version.find_by(item_type: entry.item_type, event: "destroy", item_id: entry.item_id)
      end
    end
  end
end
