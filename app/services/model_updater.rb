class ModelUpdater
  def self.call
    
    PandaScore::Serie.where("updated_at > ?", UpdateTracker.second_to_last_run_time).each do |ps_serie|
      ApplicationSeeder::CreateOrUpdateSerie.new(ps_serie).call
    end

    PandaScore::Tournament.where("updated_at > ?", UpdateTracker.second_to_last_run_time).each do |ps_tournament|
      ApplicationSeeder::CreateOrUpdateTournament.new(ps_tournament).call

      tournament = ps_tournament.tournament
      ps_tournament.panda_score_teams.each do |ps_team|
        ApplicationSeeder::CreateOrUpdateTeam.new(ps_team: ps_team, tournament: tournament).call
      end
    end

    PandaScore::Match.where("updated_at > ?", UpdateTracker.second_to_last_run_time).each do |ps_match|
      ApplicationSeeder::CreateOrUpdateMatch.new(ps_match).call
    end

    PandaScore::Game.where("updated_at > ?", UpdateTracker.second_to_last_run_time).each do |ps_game|
      ApplicationSeeder::CreateOrUpdateGame.new(ps_game).call
    end
  end
end