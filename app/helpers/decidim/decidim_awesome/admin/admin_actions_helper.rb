# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      module AdminActionsHelper
        def admin_actions_table_rows(admin_actions)
          admin_actions.map do |log|
            user = Decidim::User.find(log.changeset["decidim_user_id"].compact.first)
            removal_date = @removal_dates.find { |date| date.item_id == log.item_id }.try(:created_at)
            content_tag :tr do
              concat content_tag(:td, log.changeset["role"].compact.first)
              concat content_tag(:td, user.name)
              concat content_tag(:td, user.email)
              concat content_tag(:td, user.email)
              concat content_tag(:td, user.last_sign_in_at)
              concat content_tag(:td, log.changeset["created_at"].compact.first)
              concat content_tag(:td, removal_date || "Still active")
            end
          end.join.html_safe
        end
      end
    end
  end
end
