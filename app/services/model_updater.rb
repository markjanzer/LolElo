class ModelUpdater
  def self.call
    models = [PandaScore::Serie, PandaScore::Tournament, PandaScore::Match, PandaScore::Game]

    models.each do |model|
      model.where("updated_at > ?", UpdateTracker.second_to_last_run_time).each do |ps_model|
        ps_model.upsert_model
      end
    end
  end
end