module NewSeeder
  class CreateLeague
    include Memery
    
    def initialize(panda_score_id)
      @panda_score_id = panda_score_id
    end

    def call
      raise "PandaScore league data not found for #{league_data[:abbreviation]}" if panda_score_league_data.blank?

      league = PandaScore::League.find_or_initialize_by(panda_score_id: panda_score_id)
      league.update!(data: panda_score_league_data)
    end

    private

    attr_reader :panda_score_id
    
    memoize def panda_score_league_data
      PandaScore.league(id: panda_score_id)
    end
  end
end