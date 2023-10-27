# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Voting
      class ThreeFlagsProposalModalCell < ThreeFlagsBaseCell
        include Decidim::Proposals::Engine.routes.url_helpers

        def show
          render :show
        end

        def vote_instructions
          translated_attribute(current_component.settings.proposal_vote_instructions)
        end
      end
    end
  end
end
