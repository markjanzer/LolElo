class Seed::CreateTeamJob
  include Sidekiq::Job

  def perform(team_id)
    PandaScore::Team.create_from_id(team_id)
  end
end
