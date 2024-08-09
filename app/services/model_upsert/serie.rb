module ModelUpsert
  class Serie
    def self.call(panda_score_serie)
      new(panda_score_serie).call
    end

    def initialize(panda_score_serie)
      @panda_score_serie = panda_score_serie
    end

    def call
      return if excluded_serie?

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

    # LPL All-Star 2019 and LPL Online Scrims League Spring 2020
    EXCLUDED_SERIE_IDS = [2299, 2516]

    def excluded_serie?
      EXCLUDED_SERIE_IDS.include?(panda_score_serie.panda_score_id)
    end
  end
end