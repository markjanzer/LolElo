# frozen_string_literal: true

class UpdateData
  def initialize; end

  def call
    League.all.each do |league|
      # Might need to deal with pagination here.
      games_since_last_updated_at = PandaScore.request(
        path: 'matches',
        params: {
          "filter[league_id]": league.id,
          "range[end_at]": "#{last_updated_at.iso8601},#{DateTime.current.iso8601}"
        }
      )

      games_since_last_updated_at.each do |_new_game|
        byebug
      end
    end
  end

  def last_updated_at
    Match.maximum(:end_at)
  end
end
