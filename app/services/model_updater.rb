class ModelUpdater
  def self.call
    
    PandaScore::Serie.where("updated_at > ?", UpdateTracker.second_to_last_run_time).each do |ps_serie|
      ModelUpsert::Serie.call(ps_serie)
    end

    PandaScore::Tournament.where("updated_at > ?", UpdateTracker.second_to_last_run_time).each do |ps_tournament|
      ModelUpsert::Tournament.call(ps_tournament)

      tournament = ps_tournament.tournament
      ps_tournament.panda_score_teams.each do |ps_team|
        ModelUpsert::Team.call(ps_team: ps_team, tournament: tournament)
      end
    end

    PandaScore::Match.where("updated_at > ?", UpdateTracker.second_to_last_run_time).each do |ps_match|
      ModelUpsert::Match.call(ps_match)
    end

    PandaScore::Game.where("updated_at > ?", UpdateTracker.second_to_last_run_time).each do |ps_game|
      ModelUpsert::Game.call(ps_game)
    end
  end
end