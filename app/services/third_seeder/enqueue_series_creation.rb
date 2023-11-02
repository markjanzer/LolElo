module ThirdSeeder
  class EnqueueSeriesCreation
    def initialize(league_id)
      @league_id = league_id
    end

    def self.call(*)
      new(*).call
    end

    def call
      fetch_series.each do |serie|
        ::Seed::CreateSerieJob.perform_async(serie["id"])
      end
    end

    private

    attr_reader :league_id

    def fetch_series
      PandaScore.series(league_id: league_id)
    end

    # def include_serie?(name)
    #   name.split.first.match?('Spring|Summer')
    # end
  end
end