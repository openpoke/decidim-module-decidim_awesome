# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    class ExportAdminActionsJob < ApplicationJob
      queue_as :default

      def perform(current_user, format, collection_ids)
        collection = collection_to_export(collection_ids)

        serialized_collection = collection.map do |item|
          Decidim::DecidimAwesome::PaperTrailVersionSerializer.new(item).serialize
        end

        export_data = Decidim::Exporters.find_exporter(format).new(serialized_collection).export

        ExportMailer.export(current_user, "admin_actions", export_data).deliver_now
      end

      private

      def collection_to_export(ids)
        collection = Decidim::DecidimAwesome::PaperTrailVersion.role_actions

        collection = collection.where(id: ids) if ids.present?

        collection.order(id: :desc)
      end
    end
  end
end
