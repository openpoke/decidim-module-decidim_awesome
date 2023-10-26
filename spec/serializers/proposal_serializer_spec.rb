# frozen_string_literal: true

require "spec_helper"

module Decidim::Proposals
  describe ProposalSerializer do
    subject do
      described_class.new(proposal)
    end

    let!(:proposal) { create(:proposal, :accepted, component: component) }
    let!(:weight_cache) { create(:awesome_weight_cache, :with_votes, proposal: proposal) }
    let(:participatory_process) { component.participatory_space }
    let(:component) { create :proposal_component, settings: settings }
    let(:settings) do
      {
        awesome_voting_manifest: manifest
      }
    end
    let(:manifest) { :three_flags }

    let!(:proposals_component) { create(:component, manifest_name: "proposals", participatory_space: participatory_process) }

    describe "#serialize" do
      let(:serialized) { subject.serialize }

      it "serializes the id" do
        expect(serialized).to include(id: proposal.id)
      end

      it "serializes the amount of supports" do
        expect(serialized).to include(supports: proposal.proposal_votes_count)
      end

      it "serializes the weights" do
        expect(serialized).to include(weights: proposal.vote_weights)
        expect(serialized[:weights].keys.first).to eq("Red")
        expect(serialized[:weights].keys.second).to eq("Yellow")
      end

      context "when no manifest" do
        let(:manifest) { nil }

        it "serializes the weights" do
          expect(serialized).to include(weights: proposal.vote_weights)
          expect(serialized[:weights].keys.first).to eq("1")
          expect(serialized[:weights].keys.second).to eq("2")
        end
      end
    end
  end
end
