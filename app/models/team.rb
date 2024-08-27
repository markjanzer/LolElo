# frozen_string_literal: true

class Team < ApplicationRecord

  UNIQUE_COLORS = ['#e6194B', '#3cb44b', '#ffe119', '#4363d8', '#f58231', '#911eb4', '#42d4f4', '#f032e6', '#bfef45', '#fabed4', '#469990', '#dcbeff', '#9A6324', '#fffac8', '#800000', '#aaffc3', '#808000', '#ffd8b1', '#000075', '#ffffff'].freeze

  has_many :snapshots
  has_many :teams_tournaments, dependent: :destroy
  has_many :tournaments, through: :teams_tournaments

  validates :acronym, presence: true

  # has_many :series_teams
  # has_many :series, :through => :series_teams, :source => :serie
  # has_many :games, foreign_keys: [:opponent1_id, :opponent2_id]

  def elo
    return nil if last_snapshot.nil?

    last_snapshot.elo
  end

  def elo_at(datetime)
    _elo_at(datetime, :at)
  end

  def elo_before(datetime)
    _elo_at(datetime, :before)
  end

  def elo_after(datetime)
    _elo_at(datetime, :after)
  end

  def matches
    Match.where('opponent1_id = ? OR opponent2_id = ?', id, id)
  end

  private
  
  def _elo_at(datetime, comparison)
    raise "datetime is required" if datetime.nil?

    comparison_sql, direction_sql = case comparison
      when :at
        ["datetime <= ?", :desc]
      when :before
        ["datetime < ?", :desc]
      when :after
        ["datetime >= ?", :asc]
      else
        raise "comparison must be one of :at, :before, :after"
      end
    
    closest_snapshot = snapshots
      .where(comparison_sql, datetime)
      .order(datetime: direction_sql)
      .limit(1)
      .first
    
    raise "No snapshot for team (id: #{id}) exists #{comparison.to_s} #{datetime}" if closest_snapshot.nil?

    closest_snapshot.elo
  end

  def last_snapshot
    snapshots.order(datetime: :asc).last
  end
end
