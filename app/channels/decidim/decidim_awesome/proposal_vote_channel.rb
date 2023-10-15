# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    # ProposalVoteChannel handles the WebSocket connections for proposal votes.
    # It streams from a channel specific to a proposal, identified by its ID.
    class ProposalVoteChannel < ApplicationCable::Channel
      def subscribed
        stream_from "proposal_vote_#{params["proposal_id"]}_channel"
      end

      def unsubscribed
        Rails.logger.info "Client unsubscribed from proposal_vote_#{params["proposal_id"]}_channel"
      end
    end
  end
end
