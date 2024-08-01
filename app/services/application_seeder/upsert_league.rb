# I think it's a little odd that this doesn't take a panda_score_league
# This is in this file partly because of that and partly because it also takes a time zone
module ApplicationSeeder
  class UpsertLeague
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

      League.find_or_initialize_by(panda_score_id: panda_score_id)
        .update!(
          name: data["name"],
          time_zone: time_zone
        )
    end

    private

    attr_reader :panda_score_id, :time_zone
  end
end