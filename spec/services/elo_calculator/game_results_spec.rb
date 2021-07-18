# frozen_string_literal: true

# Needed for when I want to run individual specs...
require 'rails_helper'

RSpec.describe EloCalculator::GameResults do
  describe "#new_elos" do
    subject { EloCalculator::GameResults.new(winner_elo: winner_elo, loser_elo: loser_elo).new_elos }

    let(:half_of_k) { EloCalculator::K / 2 }

    context "when the teams are even in elo" do
      let(:winner_elo) { 1500 }
      let(:loser_elo) { 1500 }

      it "increases the winning team's elo by half of K" do
        new_winner_elo, _ = subject
        expect(new_winner_elo).to eq(winner_elo + half_of_k)
      end
    
      it "decreases the losing team's elo by half of K" do
        _, new_loser_elo = subject
        expect(new_loser_elo).to eq(winner_elo - half_of_k)
      end
    end

    context "when winning team has a lower elo" do
      let(:winner_elo) { 1400 }
      let(:loser_elo) { 1600 }
    
      it "increases the winning team's elo by more than half of K" do
        new_winner_elo, _ = subject
        absolute_change_in_elo = (new_winner_elo - winner_elo).abs
        expect(absolute_change_in_elo).to be > half_of_k
      end
    
      it "decreases the losing team's elo by more than half of K" do
        _, new_loser_elo = subject
        absolute_change_in_elo = (new_loser_elo - loser_elo).abs
        expect(absolute_change_in_elo).to be > half_of_k
      end
    end
    
    context "when the winning team has a higher elo" do
      let(:winner_elo) { 1600 }
      let(:loser_elo) { 1400 }
    
      it "increases the winning team's elo by less than half of K" do
        new_winner_elo, _ = subject
        absolute_change_in_elo = (new_winner_elo - winner_elo).abs
        expect(absolute_change_in_elo).to be < half_of_k
      end
    
      it "decreases the losing team's elo by less than half of K" do
        _, new_loser_elo = subject
        absolute_change_in_elo = (new_loser_elo - loser_elo).abs
        expect(absolute_change_in_elo).to be < half_of_k
      end
    end

    context "when the winning team has a drastically higher elo" do
      let(:winner_elo) { 2800 }
      let(:loser_elo) { 800 }

      it "has no effect on the winning teams elo" do
        new_winner_elo, _ = subject
        expect(new_winner_elo).to eq winner_elo
      end

      it "has no effect on the losing teams elo" do
        _, new_loser_elo = subject
        expect(new_loser_elo).to eq loser_elo
      end
    end

    context "when the winning team has a drastically lower elo" do
      let(:winner_elo) { 800 }
      let(:loser_elo) { 2800 }

      it "increase the winning team's elo by K" do
        new_winner_elo, _ = subject
        expect(new_winner_elo).to eq winner_elo + EloCalculator::K
      end

      it "decreases the winning team's elo by K" do
        _, new_loser_elo = subject
        expect(new_loser_elo).to eq loser_elo - EloCalculator::K
      end
    end

  end
end
