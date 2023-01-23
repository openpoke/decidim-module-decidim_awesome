# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      module AdminActionsHelper
        def role_from_papertrail(admin_action)
          destroy_action = PaperTrail::Version.find_by(item_type: admin_action.item_type, event: "destroy", item_id: admin_action.item_id)
          role = destroy_action&.reify&.role || admin_action.item&.role
          role == "admin" ? "administrator" : role
        end

        def participatory_space_type(admin_action)
          Decidim::ActionLog.find_by(resource_id: admin_action.changeset["decidim_user_id"].last).try(:participatory_space_type)
        end

        def admin_action_user(admin_action)
          Decidim::User.find_by(id: admin_action.changeset["decidim_user_id"].last)
        end

        def removal_date(admin_action)
          removal_date = admin_actions_destroy.find { |date| date.item_id == admin_action.item_id }.try(:created_at)

          removal_date ? I18n.l(removal_date, format: :short) : currently_active
        end

        def currently_active
          t("decidim.decidim_awesome.admin.admin_accountability.currently_active")
        end
      end
    end
  end
end
