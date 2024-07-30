module ApplicationSeeder
  class CreateOrUpdateTournament
    FILTERED_MATCH_NAMES = ["Promotion", "Promotion-Relegation"].freeze
    
    def initialize(panda_score_tournament)
      @panda_score_tournament = panda_score_tournament
    end

    def call
      return if FILTERED_MATCH_NAMES.include?(panda_score_tournament.data["name"])

      panda_score_tournament.upsert_model
    end

    private

    attr_reader :panda_score_tournament
  end
end