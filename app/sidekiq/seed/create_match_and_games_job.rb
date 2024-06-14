class Seed::CreateMatchAndGamesJob
  include Sidekiq::Job

  def perform(match_id)
    match = PandaScore::Match
      .find_or_initialize_by(panda_score_id: match_id)
      .tap { |m| m.update_from_api }

    match.data["games"].each do |game|
      PandaScore::Game.find_or_initialize_by(panda_score_id: game["id"])
        .update(data: game)
  end
end
