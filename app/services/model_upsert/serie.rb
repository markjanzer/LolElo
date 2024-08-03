module ModelUpsert
  class Serie
    def self.call(panda_score_serie)
      new(panda_score_serie).call
    end

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

    # This is probably wrong, didn't LEC just have a winter split?
    def valid_serie?
      raise "no full_name" unless panda_score_serie.data['full_name'].present?
      panda_score_serie.data['full_name'].split.first.match?('Spring|Summer')
    end
  end
end