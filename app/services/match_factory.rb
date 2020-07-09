class MatchFactory
  attr_reader :serie, :match_data
  
  def initialize(serie:, match_data:)
    @serie = serie
    @match_data = match_data
  end

  def create
    match.assign_attributes({
      end_at: end_at,
      serie: serie,
      opponent_1: opponent_1,
      opponent_2: opponent_2,
    })

    match.save!
  
    completed_games_data(match_data).each do |game_datum|
      GameFactory.new(game_data: game_datum, match: match).create
    end
  end

  private

  def match
    @match ||= Match.find_or_initialize_by(external_id: match_data["id"])
  end

  def end_at
    match_data["end_at"]
  end

  def opponent_1
    serie.teams.find_by(external_id: match_data["opponents"].first["opponent"]["id"])
  end

  def opponent_2
    serie.teams.find_by(external_id: match_data["opponents"].second["opponent"]["id"])
  end

  def completed_games_data(match_data)
    match_data["games"].reject { |game| game["forfeit"] }
  end
end