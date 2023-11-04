module PandaScoreAPISeeder
  class CreateLeague
    def initialize(league_seed_data)
      @panda_score_id = league_seed_data[:league_id]
      @time_zone = league_seed_data[:time_zone]
    end

    def call
      if time_zone.nil?
        raise 'time_zone is required'
      end

      panda_score_league = PandaScore::League.find_by(panda_score_id: panda_score_id)
  
      League.find_or_initialize_by(
        panda_score_id: panda_score_id,
        name: panda_score_league.data["name"],
        time_zone: time_zone
      ).save!
    end

    private

    attr_reader :panda_score_id, :time_zone
  end
end