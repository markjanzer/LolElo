# frozen_string_literal: true

class MatchFactory
  attr_reader :tournament, :match_data

  def initialize(tournament:, match_data:)
    @tournament = tournament
    @match_data = match_data
  end

  def create
    match.assign_attributes({
                              end_at: end_at,
                              tournament: tournament,
                              opponent_1: opponent_1,
                              opponent_2: opponent_2
                            })

    match.save!

    create_games
  end

  private

  def match
    @match ||= Match.find_or_initialize_by(external_id: match_data['id'])
  end

  def end_at
    match_data['end_at']
  end

  def opponent_1
    tournament.teams.find_by(external_id: match_data['opponents'].first['opponent']['id'])
  end

  def opponent_2
    tournament.teams.find_by(external_id: match_data['opponents'].second['opponent']['id'])
  end

  def create_games
    completed_games_data(match_data).each do |game_datum|
      create_game(game_datum)
    end
  end

  def completed_games_data(match_data)
    match_data['games'].reject { |game| game['forfeit'] }
  end

  def create_game(game_datum)
    GameFactory.new(game_data: game_datum, match: match).create
  end
end
