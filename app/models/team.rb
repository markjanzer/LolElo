class Team < ApplicationRecord
  has_many :snapshots
  has_many :series_teams
  has_many :series, :through => :series_teams, :source => :serie
  # has_many :games, foreign_keys: [:opponent_1_id, :opponent_2_id]

  def elo
    return nil if last_snapshot.nil?
    last_snapshot.elo
  end

  def elo_at(datetime)
    snapshots.where("date <= ?", datetime).order(:date).last.elo
  end

  def elo_after(date)
    snapshots.where("date >= ?", date).order(:date).first.elo
  end

  def elo_before(date)
    snapshots.where("date < ?", date).order(:date).last.elo
  end

  def matches
    Match.where("opponent_1_id = ? OR opponent_2_id = ?", id, id)
  end

  private

  def last_snapshot
    snapshots.order(:date).last
  end
end
