# frozen_string_literal: true
# I would like to refactor this a little, pass it a league and a date
# And if the date is nil then use create_snapshots_from
# Also it should be callable as a class method
module EloSnapshots
  class LeagueProcessor
    def self.call(league, create_snapshots_from=nil)
      new(league, create_snapshots_from).call
    end

    def initialize(league, create_snapshots_from=nil)
      raise "league not defined" unless league
      @league = league
      @create_snapshots_from = create_snapshots_from || first_game_without_snapshots(league)
    end

    def call
      return "No snapshots to create" unless create_snapshots_from

      Snapshot.transaction do
        league.snapshots.where("datetime >= ?", create_snapshots_from).destroy_all

        league.reload.games.where("games.end_at >= ?", create_snapshots_from).order(end_at: :asc).each do |game|
          EloSnapshots::GameProcessor.new(game).call
        end
      end
    end

    private

    attr_reader :league, :create_snapshots_from

    def first_game_without_snapshots(league)
      first_game = ActiveRecord::Base.connection.execute(
        <<-SQL
          SELECT games.end_at
          FROM games
          JOIN matches ON games.match_id = matches.id
          JOIN tournaments ON matches.tournament_id = tournaments.id
          JOIN series ON tournaments.serie_id = series.id
          JOIN leagues ON series.league_id = leagues.id
          LEFT JOIN snapshots ON snapshots.game_id = games.id
          WHERE leagues.id = #{ActiveRecord::Base.sanitize_sql(league.id)}
          GROUP BY games.id
          HAVING COUNT(snapshots.id) < 2
          ORDER BY games.end_at ASC
          LIMIT 1
        SQL
      )

      first_game.first&.[]('end_at')
    end
  end
end