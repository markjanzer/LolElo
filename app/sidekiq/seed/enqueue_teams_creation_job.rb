class Seed::EnqueueTeamsCreationJob
  include Sidekiq::Job

  def perform(tournament_id)
    fetched_teams = PandaScoreAPI.teams(tournament_id: tournament_id)
    team_ids = fetched_teams.map { |team| [team["id"]] }
    ::Seed::CreateTeamJob.perform_bulk(team_ids)
  end
end
