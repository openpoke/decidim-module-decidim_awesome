# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      module AdminActionsHelper
        def admin_actions_table_rows(admin_actions)
          admin_actions.map do |log|
            user = Decidim::User.find(log.changeset["decidim_user_id"].last)
            removal_date = admin_actions_destroy.find { |date| date.item_id == log.item_id }.try(:created_at)

            content_tag :tr do
              concat content_tag(:td, role_from_papertrail(log))
              concat content_tag(:td, user.name, class: user.name.blank? ? "text-warning" : nil)
              concat content_tag(:td, user.email, class: user.email.blank? ? "text-warning" : nil)
              concat content_tag(:td, participatory_space_type(log) || t("decidim.decidim_awesome.admin.admin_accountability.missing_info"))
              concat content_tag(:td, user.last_sign_in_at ? I18n.l(user.last_sign_in_at, format: :short) : "")
              concat content_tag(:td, I18n.l(log.changeset["created_at"].compact.last, format: :short))
              concat content_tag(:td, removal_date ? I18n.l(removal_date, format: :short) : t("decidim.decidim_awesome.admin.admin_accountability.currently_active"),
                                 class: removal_date.nil? ? "text-success" : nil)
            end
          end.join.html_safe
        end

        private

        def role_from_papertrail(log)
          logs_update = PaperTrail::Version.where(item_type: "Decidim::ParticipatoryProcessUserRole", event: %w(update))
          role = ""

          if logs_update.exists?(item_id: log.item_id)
            logs_update.map do |log_update|
              parts = log_update.object_changes.split("\n")
              role_index = parts.index("role:") + 2
              role = parts[role_index].strip.tr("^A-Za-z0-9", "")
            end.last
          else
            role = log.changeset["role"].compact.last
          end

          role == "admin" ? "administrator" : role
        end

        def participatory_space_type(log)
          Decidim::ActionLog.find_by(resource_type: "Decidim::ParticipatoryProcessUserRole",
                                     resource_id: log.changeset["decidim_user_id"][1]).try(:participatory_space_type)
        end
      end
    end
  end
end
