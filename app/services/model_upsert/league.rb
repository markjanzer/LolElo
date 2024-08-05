module ModelUpsert
  class League
    def self.call(panda_score_league:, time_zone:)
      raise 'time_zone is required' if time_zone.nil?
      raise "PandaScore::League does not exist" if panda_score_league.nil?

      ::League.find_or_initialize_by(panda_score_id: panda_score_league.panda_score_id)
        .update!(
          name: panda_score_league.data["name"],
          time_zone: time_zone
        )
    end
  end
end