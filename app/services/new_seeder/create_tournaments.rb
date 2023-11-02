module NewSeeder
  class CreateTournaments
    def self.call
      new.call
    end

    def call
      PandaScore::Serie.all.each do |serie|
        fetch_tournaments(serie.panda_score_id).each do |tournament|
          tournament_data = tournament_data(tournament["id"])
          PandaScore::Tournament.find_or_initialize_by(panda_score_id: tournament["id"])
            .update(data: tournament_data)
        end
      end
    end

    private

    def fetch_tournaments(serie_id)
      PandaScore.tournaments(serie_id: serie_id)
    end

    def fetch_tournament_data(tournament_id)
      PandaScore.tournament(id: tournament_id)
    end
  end
end