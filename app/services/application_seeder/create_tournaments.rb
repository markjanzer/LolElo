module ApplicationSeeder
  class CreateTournaments
    def initialize(serie)
      @serie = serie
    end

    def call
      panda_score_tournaments = PandaScore::Tournament.where("data ->> 'serie_id' = ?", "#{serie.panda_score_id}}")

      panda_score_tournaments.each do |ps_tournament|
        tournament = Tournament.find_or_initialize_by(panda_score_id: ps_tournament.data['id'])
        tournament.assign_attributes({
          name: ps_tournament.data['name']
        })
        serie.tournaments << tournament
      end
    end

    private

    attr_reader :serie
  end
end