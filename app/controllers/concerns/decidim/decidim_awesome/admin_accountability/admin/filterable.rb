# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module DecidimAwesome
    module AdminAccountability
      module Admin
        module Filterable
          extend ActiveSupport::Concern

          included do
            include Decidim::Admin::Filterable

            private

            def base_query
              collection
            end

            def filters
              [
                :role_type_eq,
                :participatory_space_type_eq
              ]
            end

            def filters_with_values
              {
                role_type_eq: role_types,
                participatory_space_type_eq: participatory_space_types
              }
            end

            def search_field_predicate
              :user_name_cont
            end

            def extra_allowed_params
              [:per_page]
            end

            protected

            def role_types
              %w(admin collaborator moderator valuator)
            end

            def participatory_space_types
              %w(Processes Assemblies)
            end
          end
        end
      end
    end
  end
end
