module ApplicationSeeder
  class CreateOrUpdateTournament
    def initialize(panda_score_tournament)
      @panda_score_tournament = panda_score_tournament
    end

    def call
      tournament = Tournament.find_or_initialize_by(panda_score_id: pand_score_tournament.data['id'])
      tournament.assign_attributes({
        name: pand_score_tournament.data['name'],
        tournament: serie
      })
    end

    private

    attr_reader :panda_score_tournament

    def serie
      Serie.find_by(panda_score_id: panda_score_tournament.data['serie_id'])
    end
  end
end