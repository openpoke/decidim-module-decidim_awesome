# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      module AdminActionsHelper
        def admin_actions_table_rows(admin_actions)
          admin_actions.map do |log|
            user = Decidim::User.find(log.changeset["decidim_user_id"].compact.first)
            removal_date = removal_dates.find { |date| date.item_id == log.item_id }.try(:created_at)
            content_tag :tr do
              concat content_tag(:td, log.changeset["role"].compact.first)
              concat content_tag(:td, user.name)
              concat content_tag(:td, user.email)
              concat content_tag(:td, user.email)
              concat content_tag(:td, user.last_sign_in_at ? I18n.l(user.last_sign_in_at, format: :short) : "")
              concat content_tag(:td, I18n.l(log.changeset["created_at"].compact.first, format: :short))
              concat content_tag(:td, removal_date ? I18n.l(removal_date, format: :short) : t("decidim.decidim_awesome.admin.admin_accountability.currently_active"))
            end
          end.join.html_safe
        end

        private

        def removal_dates
          @removal_dates ||= PaperTrail::Version.where(item_type: "Decidim::ParticipatoryProcessUserRole", event: "destroy")
        end
      end
    end
  end
end
