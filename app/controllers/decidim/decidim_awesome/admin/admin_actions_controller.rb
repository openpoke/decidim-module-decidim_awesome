# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class AdminActionsController < DecidimAwesome::Admin::ApplicationController
        include NeedsAwesomeConfig

        layout "decidim/admin/users"
        before_action do
          enforce_permission_to :edit_config, :allow_admin_accountability
        end

        def index
          participatory_processes = Decidim::ParticipatoryProcess.where(organization: current_organization)
          roles = [:valuator, :admin, :moderator, :collaborator]
          user_roles = Decidim::ParticipatoryProcessUserRole.where(participatory_process: participatory_processes, role: roles)
          user_ids = user_roles.pluck(:decidim_user_id).uniq
          @user_logs = Decidim::ActionLog.where(decidim_user_id: user_ids)
          @user_roles = user_roles.index_by(&:decidim_user_id)
        end

        def export_xls
          # TODO: export to xls
        end
      end
    end
  end
end
