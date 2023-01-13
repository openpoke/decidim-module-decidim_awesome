# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class AdminActionsController < DecidimAwesome::Admin::ApplicationController
        include ConfigConstraintsHelpers
        helper ConfigConstraintsHelpers

        layout "decidim/admin/users"

        def index; end

        def export_xls
          # TODO: export to xls
        end
      end
    end
  end
end
