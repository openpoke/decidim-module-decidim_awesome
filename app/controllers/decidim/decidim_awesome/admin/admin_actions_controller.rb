# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class AdminActionsController < DecidimAwesome::Admin::ApplicationController
        include NeedsAwesomeConfig
        include Decidim::Admin::Filterable

        helper_method :admin_actions, :types_user_roles

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
          @admin_actions = PaperTrail::Version.where(item_type: types_user_roles, event: "create").map { |admin_action| AdminActionsPresenter.new(admin_action) }

          Kaminari.paginate_array(@admin_actions).page(params[:page]).per(params[:per_page])
        end

        def types_user_roles
          @types_user_roles ||= Decidim::DecidimAwesome.user_roles
        end
      end
    end
  end
end
