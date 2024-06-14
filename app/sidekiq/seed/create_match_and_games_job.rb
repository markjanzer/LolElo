class Seed::CreateMatchAndGamesJob
  include Sidekiq::Job

  def perform(match_id)
    match = PandaScore::Match.find_or_initialize_by(panda_score_id: match_id)
    match.update_from_api
    match.create_or_update_games
  end
end
