# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class AdminActionsController < DecidimAwesome::Admin::ApplicationController
        include NeedsAwesomeConfig
        include Decidim::Admin::Filterable
        helper_method :admin_actions

        layout "decidim/admin/users"
        before_action do
          enforce_permission_to :edit_config, :allow_admin_accountability
        end

        def index; end

        def export_xls
          # TODO: export to xls
        end

        private

        def admin_actions
          @admin_actions = PaperTrail::Version.where(item_type: "Decidim::ParticipatoryProcessUserRole", event: "create")
                                              .page(params[:page]).per(params[:per_page])
        end
      end
    end
  end
end
