module ModelUpsert
  class Tournament
    def self.call(panda_score_tournament)
      new(panda_score_tournament).call
    end
    
    def initialize(panda_score_tournament)
      @panda_score_tournament = panda_score_tournament
    end

    def call
      return if reject?

      ::Tournament
        .find_or_initialize_by(panda_score_id: panda_score_tournament.panda_score_id)
        .update!(
          name: panda_score_tournament.data['name'],
          serie: panda_score_tournament.serie
        )
    end

    private

    attr_reader :panda_score_tournament

    FILTERED_MATCH_NAMES = ["Promotion", "Promotion-Relegation"].freeze

    def reject?
      return FILTERED_MATCH_NAMES.include?(panda_score_tournament.data["name"])
    end
  end
end