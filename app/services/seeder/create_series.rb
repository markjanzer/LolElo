class Seeder
  class CreateSeries
    def initialize(league)
      @league = league
    end

    def call
      league_series = PandaScore::Serie.where("data ->> 'league_id' = ?", "#{league.panda_score_id}}")

      valid_series = league_series.select { |serie| valid_serie?(serie) }

      valid_series.each do |serie| 
        new_serie = Serie.find_or_initialize_by(panda_score_id: serie.data['id'])
        new_serie.assign_attributes({
          year: serie.data["year"],
          begin_at: serie.data["begin_at"],
          full_name: serie.data["full_name"],
        })
        league.series << new_serie
      end
    end

    private

    attr_reader :league

    def valid_serie?(serie)
      # This is probably wrong, didn't LEC just have a winter split?
      serie.data['full_name'].split.first.match?('Spring|Summer')
    end
  end
end