# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class AdminAccountabilityController < DecidimAwesome::Admin::ApplicationController
        include NeedsAwesomeConfig
        include Decidim::Admin::Filterable

        helper_method :admin_actions, :global?

        layout "decidim/admin/users"

        before_action do
          enforce_permission_to :edit_config, :admin_accountability
        end

        def index; end

        def export
          # TODO: export to xls, csv
        end

        private

        def admin_actions
          @admin_actions ||= paginate(role_actions)
        end

        def role_actions
          global? ? PaperTrailVersion.admin_role_actions : PaperTrailVersion.space_role_actions
        end

        def global?
          params[:admins] == "true"
        end
      end
    end
  end
end
