# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Updater do
  describe "#call" do
    # This is a little tricky because it continues to run the code
    # Which attempts to access the API, and I don't want to spec everything out
    # This might be a little easier when I move logic around.
    it "calls create_new_tournaments with each ps_serie that hasn't finished"

    it "updates the ps_serie"
    it "does not do anything if the serie is complete"
    
    it "calls create_new_matches with each non-complete tournament"
    it "update each non-complete tournament"
    it "does nothing if the tournament is complete"

    it "calls create_new_games for each non-complete match"
    it "updates each non-complete match"
    it "does nothing if the match is complete"

    it "updates each non-complete game"
    it "does nothing if the game is complete"
  end
end