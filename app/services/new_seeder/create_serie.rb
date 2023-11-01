module NewSeeder
  class CreateSerie
    def initialize(id)
      @id = id
    end

    def call
      raise "data is nil for #{id}" if serie_data.nil?

      serie = PandaScore::Serie.find_or_initialize_by(panda_score_id: id)
      serie.update(data: serie_data)
    end

    private

    attr_reader :id

    def serie_data
      @series_data ||= PandaScore.serie(id: id)
    end
  end
end