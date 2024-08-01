module ModelUpsert
  class Serie
    def initialize(panda_score_serie)
      @panda_score_serie = panda_score_serie
    end

    def call
      return unless valid_serie?

      ::Serie.find_or_initialize_by(panda_score_id: panda_score_serie.panda_score_id)
        .update!(
          year: panda_score_serie.data["year"],
          begin_at: panda_score_serie.data["begin_at"],
          full_name: panda_score_serie.data["full_name"],
          league: panda_score_serie.league
        )
    end

    
    private
    
    attr_reader :panda_score_serie

    # This is copies from Serie.rb, ideally that one goes away
    def valid_serie?
      # This is probably wrong, didn't LEC just have a winter split?
      panda_score_serie.data['full_name'].split.first.match?('Spring|Summer')
    end
  end
end