module PandaScoreAPISeeder
  class CreateTeam
    def initialize(team_id)
      @team_id = team_id
    end

    def self.call(*)
      new(*).call
    end

    def call
      # Prevent duplicate requests for the same teams from different tournaments
      # Might want to remove if we want to use these scripts to update
      return if PandaScore::Team.exists?(panda_score_id: team_id)

      PandaScore::Team.find_or_initialize_by(panda_score_id: team_id)
        .update(data: fetch_team_data)
    end

    private

    attr_reader :team_id

    def fetch_team_data
      PandaScoreAPI.team(id: team_id)
    end
  end
end