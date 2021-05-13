# frozen_string_literal: true

class GameFactory
  attr_reader :game_data

  def initialize(game_data:)
    @game_data = game_data
  end

  def call
    if game_data.nil?
      raise "game_data is required"
    end

    if winner.nil?
      raise "winning team does not exist"
    end

    game.assign_attributes({
      end_at: end_at,
      winner: winner
    })

    game
  end

  private

  # There is at least one game without an end at that timestamp that wasn't forfeited.
  def end_at
    if game_data['end_at'].nil?
      DateTime.parse(game_data['begin_at']) + game_data['length'].seconds
    else
      game_data['end_at']
    end
  end

  def winner
    Team.find_by(external_id: game_data['winner']['id'])
  end

  def game
    @game ||= Game.find_or_initialize_by(external_id: game_data['id'])
  end
end
