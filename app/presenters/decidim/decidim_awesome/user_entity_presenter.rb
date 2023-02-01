# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    class UserEntityPresenter < RoleBasePresenter
      # def role_name
      #   type = I18n.t(role, scope: "decidim.decidim_awesome.admin.admin_accountability.roles", default: role)
      #   return type unless html

      #   "<span class=\"#{role_class}\">#{type}</span>".html_safe
      # end

      # def user
      #   @user ||= Decidim::User.find_by(id: entry.changeset["decidim_user_id"]&.last)
      # end
    end
  end
end
