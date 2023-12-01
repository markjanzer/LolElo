# frozen_string_literal: true

class Serie < ApplicationRecord
  belongs_to :league
  has_many :tournaments
  has_many :teams, -> { distinct }, through: :tournaments
  has_many :matches, through: :tournaments
  has_many :snapshots

  # I want to remove this from here but tests break atm
  def self.valid_name?(name)
    name.split.first.match?('Spring|Summer')
  end

  def panda_score_serie
    PandaScore::Serie.find_by(panda_score_id: panda_score_id)
  end

  def initial_snapshots
    query = <<-SQL
      WITH ranked_snapshots AS (
          SELECT
              snapshots.*,
              ROW_NUMBER() OVER (PARTITION BY snapshots.team_id ORDER BY snapshots.datetime DESC) AS rn
          FROM series
          JOIN tournaments ON tournaments.serie_id = series.id
          JOIN teams_tournaments ON teams_tournaments.tournament_id = tournaments.id
          JOIN teams ON teams_tournaments.team_id = teams.id
          JOIN snapshots ON snapshots.team_id = teams.id
          WHERE series.id = #{id} AND snapshots.datetime <= series.begin_at
      )
      SELECT *
      FROM ranked_snapshots
      WHERE rn = 1;
    SQL

    result = Snapshot.find_by_sql(query)
  end
end

# Serie.first.get_data(path: "/lol/series", params: {
#   "filter[league_id]": 4198,
#   "filter[year]": 2019,
#   "filter[season]": "Summer"
# })
