# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    # This class acts as a registry for processors. Check the docs on the
    # `ContentBlockManifest` class to learn how they work.
    #
    # In order to register a processor, you can follow this example:
    #
    #     Decidim.processors.register(:homepage, :global_stats) do |processor|
    #       processor.cell = "decidim/processors/stats_block"
    #       processor.public_name_key = "decidim.processors.stats_block.name"
    #       processor.settings_form_cell = "decidim/processors/stats_block_settings_form"
    #
    #       processor.settings do |settings|
    #         settings.attribute :minimum_priority_level,
    #                            type: :integer
    #                            default: lambda { StatsRegistry::HIGH_PRIORITY }
    #       end
    #     end
    #
    # processors can also register attached images. Here's an example of a
    # processor with 4 attached images:
    #
    #     Decidim.processors.register(:homepage, :carousel) do |processor|
    #       processor.cell = "decidim/processors/carousel_block"
    #       processor.public_name_key = "decidim.processors.carousel_block.name"
    #
    #       processor.images = [
    #         {
    #           name: :image_1,
    #           uploader: "Decidim::ImageUploader"
    #         },
    #         {
    #           name: :image_2,
    #           uploader: "Decidim::ImageUploader"
    #         }
    #       ]
    #     end
    #
    # You will probably want to register your processors in an initializer in
    # the `engine.rb` file of your module.
    class WeightedVotingRegistry
      # Public: Registers a processor for the home page.
      #
      # scope - a symbol or string representing the scope of the processor.
      #         Will be persisted as a string.
      # name - a symbol representing the name of the processor
      # &block - The processor definition.
      #
      # Returns nothing. Raises an error if there's already a processor
      # registered with that name.
      def register(scope, name)
        scope = scope.to_s
        block_exists = processors[scope].any? { |processor| processor.name == name }

        if block_exists
          raise(
            ProcessorAlreadyRegistered,
            "There's a processor already registered with the name `:#{name}` for the scope `:#{scope}, must be unique"
          )
        end

        # processor = ProcessorManifest.new(name: name)

        # yield(processor)

        # processor.validate!
        # processors[scope].push(processor)
      end

      def for(scope)
        processors[scope.to_s]
      end

      def all
        processors
      end

      class ProcessorAlreadyRegistered < StandardError; end

      private

      def processors
        @processors ||= Hash.new { |h, k| h[k] = [] }
      end
    end
  end
end
