class Seed::CreateTournamentJob
  include Sidekiq::Job

  def perform(tournament_id)
    PandaScoreAPISeeder::CreateTournament.call(tournament_id)
  end
end
