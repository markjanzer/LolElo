require_relative '../../../config/environment'

def print_tournament(ps_tournament)
  serie = ps_tournament.panda_score_serie
  {
    tournament: ps_tournament.data["name"],
    serie: serie.data["full_name"],
    league: serie.data["league"]["name"],
  }
end

PandaScore::Tournament.all.each do |ps_tournament|
  puts print_tournament(ps_tournament)
end