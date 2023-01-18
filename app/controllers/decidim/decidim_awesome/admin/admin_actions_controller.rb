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
          @user_logs = Decidim::ActionLog.for_admin
                                         .where(resource_type: "Decidim::ParticipatoryProcessUserRole",
                                                organization: current_organization)
                                         .where(action: %w(create delete))
        end

        def export_xls
          # TODO: export to xls
        end
      end
    end
  end
end
