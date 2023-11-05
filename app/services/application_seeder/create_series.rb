module ApplicationSeeder
  class CreateSeries
    def initialize(panda_score_league_id)
      @panda_score_league_id = panda_score_league_id
    end

    def call
      panda_score_league = PandaScore::League.find_by(panda_score_id: panda_score_league_id)
      panda_score_series = panda_score_league.panda_score_series

      valid_series = panda_score_series.select { |serie| valid_serie?(serie) }

      valid_series.each(&:create_or_update_serie)
    end

    private

    attr_reader :panda_score_league_id

    # This is copies from Serie.rb, ideally that one goes away
    def valid_serie?(serie)
      # This is probably wrong, didn't LEC just have a winter split?
      serie.data['full_name'].split.first.match?('Spring|Summer')
    end
  end
end