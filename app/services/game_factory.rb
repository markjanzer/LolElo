class GameFactory
  attr_reader :match, :game_data
  
  def initialize(match:, game_data:)
    @match = match
    @game_data = game_data
  end

  def create
    game.assign_attributes({
      match: match,
      end_at: end_at,
      winner: winner
    })
    game.save!
  end

  private

  # There is at least one game without an end at that timestamp that wasn't forfeited.
  def end_at
    if game_data["end_at"].nil?
      return DateTime.parse(game_data["begin_at"]) + game_data["length"].seconds
    else
      return game_data["end_at"]
    end
  end

  def winner
    Team.find_by(external_id: game_data["winner"]["id"])
  end

  def game
    @game ||= Game.find_or_initialize_by(external_id: game_data["id"])
  end
end