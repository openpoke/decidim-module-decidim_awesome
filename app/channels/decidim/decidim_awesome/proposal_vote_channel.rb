# frozen_string_literal: true
module Decidim
  module DecidimAwesome
    class ProposalVoteChannel < ApplicationCable::Channel
      def subscribed
        stream_from "proposal_vote_#{params["proposal_id"]}_channel"
      end

      def unsubscribed
        # cleanup needed when channel is unsubscribed
      end
    end
  end
end
