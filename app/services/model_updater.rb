class ModelUpdater
  def self.call
    last_model_update = UpdateTracker.last_model_update
    
    PandaScore::Serie.where("updated_at > ?", last_model_update).each do |ps_serie|
      ModelUpsert::Serie.call(ps_serie)
    end

    PandaScore::Tournament.where("updated_at > ?", last_model_update).each do |ps_tournament|
      next unless ModelUpsert::Tournament.call(ps_tournament)

      tournament = ps_tournament.tournament
      ps_tournament.panda_score_teams.each do |ps_team|
        ModelUpsert::Team.call(ps_team: ps_team, tournament: tournament)
      end
    end

    PandaScore::Match.where("updated_at > ?", last_model_update).each do |ps_match|
      ModelUpsert::Match.call(ps_match)
    end

    PandaScore::Game.where("updated_at > ?", last_model_update).each do |ps_game|
      ModelUpsert::Game.call(ps_game)
    end

    UpdateTracker.record_model_update
  end
end