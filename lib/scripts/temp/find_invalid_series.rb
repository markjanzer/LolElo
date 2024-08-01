require_relative '../../../config/environment'

def find_serie_with_begin_at_after_game_end_at
  incorrect_series = []
  PandaScore::Serie.all.each do |ps_serie|
    serie_begin_at = DateTime.parse(ps_serie.data["begin_at"])
    games = games_for_serie(ps_serie)
    games.each do |game|
      if serie_begin_at < DateTime.parse(game.data["end_at"])
        incorrect_series << ps_serie
        break
      end
    end
  end

  puts incorrect_series
  puts incorrect_series.count
end

def games_for_serie(ps_serie)
  ps_tournaments = PandaScore::Tournament.where("(data->'serie'->>'id')::int = ?", ps_serie.panda_score_id)
  ps_matches = PandaScore::Match.where("(data->'tournament'->>'id')::int IN (?)", ps_tournaments.map(&:panda_score_id))
  PandaScore::Game.where("(data->'match'->>'id')::int IN (?)", ps_matches.map(&:panda_score_id))
end

find_serie_with_begin_at_after_game_end_at

