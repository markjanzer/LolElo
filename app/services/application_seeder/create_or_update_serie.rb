module ApplicationSeeder
  class CreateSerie
    def initialize(panda_score_serie)
      @panda_score_serie = panda_score_serie
    end

    def call
      return unless valid_serie?

      new_serie = Serie.find_or_initialize_by(panda_score_id: panda_score_id)
      new_serie.update(
        year: data["year"],
        begin_at: data["begin_at"],
        full_name: data["full_name"],
        league: league
      )
    end

    private

    attr_reader :panda_score_serie

    # This is copies from Serie.rb, ideally that one goes away
    def valid_serie?
      # This is probably wrong, didn't LEC just have a winter split?
      panda_score_serie.data['full_name'].split.first.match?('Spring|Summer')
    end

    def league
      League.find_by(panda_score_id: panda_score_serie.data["league_id"])
    end
  end
end