# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    # This class serializes a AdminAccountability so can be exported to CSV, JSON or other
    # formats.
    class PaperTrailVersionSerializer < Decidim::Exporters::Serializer
      include Decidim::ApplicationHelper
      include Decidim::ResourceHelper
      include Decidim::TranslationsHelper

      # Public: Initializes the serializer with a admin actions.
      def initialize(admin_action)
        @admin_action = admin_action
      end

      # Public: Exports a hash with the serialized data for this admin action.
      def serialize
        {
          role: admin_action.item.role,
          user_name: admin_action.item.user.name,
          user_email: admin_action.item.user.email,
          participatory_space_type: admin_action.item_type,
          participatory_space_title: translated_attribute(admin_action.item.participatory_space.title),
          last_sign_in_at: admin_action.item.user.last_sign_in_at || I18n.t("decidim.decidim_awesome.admin.admin_accountability.never_logged"),
          role_created_at: admin_action.item.created_at,
          role_removed_at: admin_action.reify&.created_at || I18n.t("decidim.decidim_awesome.admin.admin_accountability.currently_active")
        }
      end

      private

      attr_reader :admin_action
    end
  end
end
