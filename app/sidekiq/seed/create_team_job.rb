class Seed::CreateTeamJob
  include Sidekiq::Job

  def perform(team_id)
    ThirdSeeder::CreateTeam.call(team_id)
  end
end
