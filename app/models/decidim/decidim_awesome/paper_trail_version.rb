# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    class PaperTrailVersion < PaperTrail::Version
      default_scope { order("created_at DESC") }
      scope :role_actions, -> { where(item_type: Decidim::DecidimAwesome.admin_user_roles.keys, event: "create") }

      def presenter
        @presenter ||= Decidim::DecidimAwesome.admin_user_roles[item_type].safe_constantize
      end

      def present
        @present ||= presenter.new(self, html: true)
      end
    end
  end
end
