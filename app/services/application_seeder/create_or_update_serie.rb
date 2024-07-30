module ApplicationSeeder
  class CreateOrUpdateSerie
    def initialize(panda_score_serie)
      @panda_score_serie = panda_score_serie
    end

    def call
      return unless valid_serie?

      panda_score_serie.upsert_model
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