# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    class PaperTrailVersion < PaperTrail::Version
      default_scope { order("created_at DESC") }
      scope :space_role_actions, -> { where(item_type: Decidim::DecidimAwesome.participatory_space_roles, event: "create") }
      scope :admin_role_actions, lambda {
        where(item_type: "Decidim::UserBaseEntity", event: %w(create update))
          .where("object_changes LIKE '%\nroles:\n%' OR object_changes LIKE '%\nadmin:\n- false\n%'")
      }

      def present(html: true)
        @present ||= if item_type == "Decidim::UserBaseEntity"
                       UserEntityPresenter.new(self, html: html)
                     else
                       ParticipatorySpaceRolePresenter.new(self, html: html)
                     end
      end
    end
  end
end
