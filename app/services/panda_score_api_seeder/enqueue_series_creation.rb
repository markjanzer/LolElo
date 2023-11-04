module PandaScoreAPISeeder
  class EnqueueSeriesCreation
    def initialize(league_id)
      @league_id = league_id
    end

    def self.call(*)
      new(*).call
    end

    def call
      serie_ids = fetch_series.map { |serie| [serie["id"]] }
      ::Seed::CreateSerieJob.perform_bulk(serie_ids)
    end

    private

    attr_reader :league_id

    def fetch_series
      PandaScoreAPI.series(league_id: league_id)
    end

    # def include_serie?(name)
    #   name.split.first.match?('Spring|Summer')
    # end
  end
end