module ThirdSeeder
  class CreateTeam
    def initialize(team_id)
      @team_id = team_id
    end

    def self.call(*)
      new(*).call
    end

    def call
      PandaScore::Team.find_or_initialize_by(panda_score_id: team_id)
        .update(data: fetch_team_data)
    end

    private

    attr_reader :team_id

    def fetch_team_data
      PandaScore.team(id: team_id)
    end
  end
end