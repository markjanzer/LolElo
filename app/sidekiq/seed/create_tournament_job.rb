class Seed::CreateTournamentJob
  include Sidekiq::Job

  def perform(tournament_id)
    ThirdSeeder::CreateTournament.call(tournament_id)
  end
end
