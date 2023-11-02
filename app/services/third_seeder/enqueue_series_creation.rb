module ThirdSeeder
  class EnqueueSeriesCreation
    def initialize(league_id)
      @league_id = league_id
    end

    def self.call(*)
      new(*).call
    end

    def call
      fetch_series(league_id)
        # .filter { |serie| include_serie?(serie["name"]) }
        .each do |serie|
          Seed::CreateSerieJob.perform_async(serie["id"])
        end
    end

    private

    def fetch_series(league_id)
      PandaScore.series(league_id: league_id)
    end

    # def include_serie?(name)
    #   name.split.first.match?('Spring|Summer')
    # end
  end
end