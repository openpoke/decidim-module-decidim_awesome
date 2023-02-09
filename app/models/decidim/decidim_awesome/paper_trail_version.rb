# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    class PaperTrailVersion < PaperTrail::Version
      default_scope { order("created_at DESC") }
      scope :role_actions, -> { where(item_type: ::Decidim::DecidimAwesome.admin_user_roles, event: "create") }

      def present
        @present ||= if item_type.in?(Decidim::DecidimAwesome.admin_user_roles)
                       PaperTrailRolePresenter.new(self)
                     else
                       self
                     end
      end

      # ransacker :user_name do
      #     Arel.sql("(SELECT DISTINCT decidim_users.name
      #                      FROM decidim_users
      #                      JOIN #{item_type.constantize.table_name} ON decidim_users.id = #{item_type.constantize.table_name}.decidim_user_id
      #                      WHERE #{item_type.constantize.table_name} = versions.item_id)")
      # end

      ransacker :user_name do
        query = <<-SQL.squish
        (
            SELECT decidim_users.name
            FROM decidim_users
            JOIN decidim_participatory_process_user_roles ON decidim_users.id = decidim_participatory_process_user_roles.decidim_user_id
            WHERE decidim_participatory_process_user_roles.id = versions.item_id
            UNION
            SELECT decidim_users.name
            FROM decidim_users
            JOIN decidim_assembly_user_roles ON decidim_users.id = decidim_assembly_user_roles.decidim_user_id
            WHERE decidim_assembly_user_roles.id = versions.item_id
        )
        SQL
        Arel.sql(query)
      end
    end
  end
end
