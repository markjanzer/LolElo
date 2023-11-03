module NewSeeder
  class CreateSeries
    def self.call
      new.call
    end

    def call
      PandaScore::League.all.each do |league|
        fetch_series(league.panda_score_id)
          .filter { |serie| include_serie?(serie["name"]) }
          .each do |serie|
            serie_data = fetch_serie_data(serie["id"])
            PandaScore::Serie.find_or_initialize_by(panda_score_id: serie["id"])
              .update(data: serie_data)
          end
      end
    end

    private

    def fetch_series(league_id)
      PandaScoreAPI.series(league_id: league_id)
    end

    def fetch_serie_data(serie_id)
      PandaScoreAPI.serie(id: serie_id)
    end

    def include_serie?(name)
      name.split.first.match?('Spring|Summer')
    end
  end
end