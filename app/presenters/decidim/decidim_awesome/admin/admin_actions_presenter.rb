# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class AdminActionsPresenter < Decidim::Log::BasePresenter
        delegate :created_at, to: :@admin_action

        def initialize(admin_action)
          @admin_action = admin_action
        end

        def role
          role = destroy_action(@admin_action)&.reify&.role || @admin_action.item&.role
          role == "admin" ? "administrator" : role
        end

        def participatory_space_type
          Decidim::ActionLog.find_by(resource_id: @admin_action.changeset["decidim_user_id"].last).try(:participatory_space_type)
        end

        def user
          Decidim::User.find_by(id: @admin_action.changeset["decidim_user_id"].last)
        end

        def removal_date
          removal_date = destroy_action(@admin_action)&.created_at
          removal_date ? I18n.l(removal_date, format: :short) : currently_active
        end

        def admin_actions_destroy
          @admin_actions_destroy ||= PaperTrail::Version.where(item_type: types_user_roles, event: "destroy")
        end

        def currently_active
          I18n.t("decidim.decidim_awesome.admin.admin_accountability.currently_active", default: "Currently active")
        end

        private

        def destroy_action(admin_action)
          PaperTrail::Version.find_by(item_type: admin_action.item_type, event: "destroy", item_id: admin_action.item_id)
        end
      end
    end
  end
end
