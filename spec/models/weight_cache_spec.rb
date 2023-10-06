# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
  describe VoteWeight do
    subject { weight_cache }

    let(:weight_cache) { create(:awesome_weight_cache) }
    let(:proposal) { create(:proposal) }

    it { is_expected.to be_valid }

    it "has a proposal associated" do
      expect(weight_cache.proposal).to be_a(Decidim::Proposals::Proposal)
    end

    it "the associated proposal has a weight cache" do
      expect(weight_cache.proposal.weight_cache).to eq(weight_cache)
    end

    context "when proposal is destroyed" do
      let!(:weight_cache) { create(:awesome_weight_cache, proposal: proposal) }

      it "destroys the proposal weight" do
        expect { proposal.destroy }.to change { Decidim::DecidimAwesome::WeightCache.count }.by(-1)
      end
    end

    context "when proposal weight is destroyed" do
      let!(:weight_cache) { create(:awesome_weight_cache, proposal: proposal) }

      it "does not destroy the proposal" do
        expect { weight_cache.destroy }.not_to change { Decidim::Proposals::ProposalVote.count }
      end
    end

    context "when vote weight is" do
      describe "created" do
        it "increments the weight cache" do
          expect { create(:proposal_vote, proposal: proposal) }.to change { proposal.votes.count }.by(1)
          expect { create(:awesome_vote_weight, vote: proposal.votes.first, weight: 3) }.to change { Decidim::DecidimAwesome::WeightCache.count }.by(1)
          expect(proposal.weight_cache.totals).to eq({ "3" => 1 })
        end

        context "when cache already exists" do
          let(:another_proposal) { create :proposal, component: proposal.component }
          let!(:weight_cache) { create(:awesome_weight_cache, :with_votes, proposal: proposal) }
          let!(:another_weight_cache) { create(:awesome_weight_cache, :with_votes, proposal: another_proposal) }

          it "has weights and votes" do
            expect(weight_cache.reload.totals).to eq({ "1" => 1, "2" => 1, "3" => 1, "4" => 1, "5" => 1 })
          end

          it "increments the weight cache" do
            create(:awesome_vote_weight, vote: create(:proposal_vote, proposal: proposal), weight: 1)
            create(:awesome_vote_weight, vote: create(:proposal_vote, proposal: proposal), weight: 3)
            create(:awesome_vote_weight, vote: create(:proposal_vote, proposal: proposal), weight: 3)
            expect(weight_cache.reload.totals).to eq({ "1" => 2, "2" => 1, "3" => 3, "4" => 1, "5" => 1 })
          end
        end
      end

      describe "updated" do
        it "increments the weight cache" do
        end

        it "decreases the weight cache" do
        end
      end

      describe "destroyed" do
        it "decreases the weight cache" do
        end
      end
    end
  end
end
