# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class AdminActionsController < DecidimAwesome::Admin::ApplicationController
        include NeedsAwesomeConfig

        layout "decidim/admin/users"

        def index
          enforce_permission_to :index, :admin_accountability
        end

        def export_xls
          # TODO: export to xls
        end
      end
    end
  end
end
