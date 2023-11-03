class Seeder
  class CreateTournaments
    def initialize(serie)
      @serie = serie
    end

    def call
      tournaments_data.each do |tournament_data|
        serie.tournaments << new_tournament(tournament_data)
      end
    end

    private

    attr_reader :serie

    def tournaments_data
      @tournaments_data ||= PandaScoreAPI.tournaments(serie_id: serie.panda_score_id)
    end

    def new_tournament(tournament_data)
      TournamentFactory.new(tournament_data).call
    end
  end
end