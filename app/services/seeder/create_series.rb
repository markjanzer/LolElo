class Seeder
  class CreateSeries
    def initialize(league)
      @league = league
    end

    def call
      valid_series_data.each do |serie_data|
        league.series << new_serie(serie_data)
      end
    end

    def create_last
      league.series << new_serie(valid_series_data.last)
    end

    private

    attr_reader :league

    def series_data
      @series_data ||= PandaScore.series(league_id: league.panda_score_id)
    end

    def valid_series_data
      @valid_series_data ||= series_data.select { |serie_data| valid_serie(serie_data) }
    end

    def valid_serie(serie_data)
      Serie.valid_name?(serie_data['full_name'])
    end

    def new_serie(serie_data)
      SerieFactory.new(serie_data).call
    end

  end
end