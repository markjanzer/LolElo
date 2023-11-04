class Seed::CreateTournamentJob
  include Sidekiq::Job

  def perform(tournament_id)
    ApplicationSeeder::CreateTournament.call(tournament_id)
  end
end
