import consumer from "./consumer"

document.addEventListener('DOMContentLoaded', () => {
  const voteBlocks = document.querySelectorAll(".vote-block");

  voteBlocks.forEach((block) => {
    const proposalId = block.id.replace("vote-proposal-", "");

    consumer.subscriptions.create({ channel: "Decidim::DecidimAwesome::ProposalVoteChannel", proposal_id: proposalId }, {
      connected() {
        console.log("Connected to Decidim::DecidimAwesome::ProposalVoteChannel");
      },

      disconnected() {
        console.log("Disconnected from Decidim::DecidimAwesome::ProposalVoteChannel");
      },

      received(data) {
        console.log("Received data from Decidim::DecidimAwesome::ProposalVoteChannel", data);

        const voteCounterElement1 = block.querySelector(`.vote-count[data-id="${proposalId}"][data-weight="1"]`);
        const voteCounterElement2 = block.querySelector(`.vote-count[data-id="${proposalId}"][data-weight="2"]`);
        const voteCounterElement3 = block.querySelector(`.vote-count[data-id="${proposalId}"][data-weight="3"]`);

        if (voteCounterElement1) {
          voteCounterElement1.textContent = data.vote_count_1;
        }
        if (voteCounterElement2) {
          voteCounterElement2.textContent = data.vote_count_2;
        }
        if (voteCounterElement3) {
          voteCounterElement3.textContent = data.vote_count_3;
        }
      }
    });
  });
});
