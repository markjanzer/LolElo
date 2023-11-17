module ApplicationSeeder
  class CreateOrUpdateTournament
    FILTERED_MATCH_NAMES = ["Promotion", "Promotion-Relegation"].freeze
    
    def initialize(panda_score_tournament)
      @panda_score_tournament = panda_score_tournament
    end

    def call
      return if FILTERED_MATCH_NAMES.include?(panda_score_tournament.data["name"])

      tournament = Tournament.find_or_initialize_by(panda_score_id: panda_score_tournament.panda_score_id)
      tournament.update!(
        name: panda_score_tournament.data['name'],
        serie: panda_score_tournament.serie
      )
    end

    private

    attr_reader :panda_score_tournament
  end
end