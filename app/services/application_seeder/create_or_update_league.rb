module ApplicationSeeder
  class CreateOrUpdateLeague
    def initialize(panda_score_id:, time_zone:)
      @panda_score_id = panda_score_id
      @time_zone = time_zone
    end

    def call
      raise 'time_zone is required' if time_zone.nil?

      panda_score_league = PandaScore::League.find_by(panda_score_id: panda_score_id)

      if panda_score_league.nil?
        raise "PandaScore::League with id #{panda_score_id} does not exist"
      end
    
      league = League.find_or_initialize_by(panda_score_id: panda_score_id)
      league.update!(
        name: panda_score_league.data["name"],
        time_zone: time_zone
      )
    end

    private

    attr_reader :panda_score_id, :time_zone
  end
end