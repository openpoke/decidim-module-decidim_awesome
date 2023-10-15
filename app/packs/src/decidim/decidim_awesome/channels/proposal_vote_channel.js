import consumer from "./consumer"

const VOTE_WEIGHTS = [1, 2, 3];

const updateElementText = (element, text) => {
  if (element) {
    element.textContent = text;
  }
};

const updateSingleVoteCounter = (block, proposalId, weight, data) => {
  const selector = `.vote-count[data-id="${proposalId}"][data-weight="${weight}"]`;
  const voteCounterElement = block.querySelector(selector);
  updateElementText(voteCounterElement, data[`vote_count_${weight}`]);
};

const updateVoteCounters = (block, { proposal_id: proposalId, ...data }) => {
  VOTE_WEIGHTS.forEach(weight => updateSingleVoteCounter(block, proposalId, weight, data));
};

const updateColorVotes = ({ proposal_id: proposalId, ...data }) => {
  const colors = {
    green: 1,
    yellow: 2,
    red: 3
  };

  Object.entries(colors).forEach(([color, weight]) => {
    const element = document.getElementById(`${color}-votes-${proposalId}`);
    updateElementText(element, `${color[0].toUpperCase()}: ${data[`vote_count_${weight}`]}`);
  });
};

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
        updateVoteCounters(block, data);
        updateColorVotes(data);
      }
    });
  });
});
