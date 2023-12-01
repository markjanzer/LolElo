# frozen_string_literal: true

class Team < ApplicationRecord

  UNIQUE_COLORS = ['#e6194B', '#3cb44b', '#ffe119', '#4363d8', '#f58231', '#911eb4', '#42d4f4', '#f032e6', '#bfef45', '#fabed4', '#469990', '#dcbeff', '#9A6324', '#fffac8', '#800000', '#aaffc3', '#808000', '#ffd8b1', '#000075', '#a9a9a9', '#000000'].freeze

  has_many :snapshots
  has_many :teams_tournaments
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
    # Not a big fan of at.
    snapshots_at = snapshots.where('datetime <= ?', datetime)

    if snapshots_at.empty?
      raise "No snapshot for team (id: #{id}) exists before or at #{datetime}"
    end
    
    snapshots_at.order(datetime: :desc).limit(1).first.elo
  end

  def elo_after(datetime)
    snapshots_after = snapshots.where('datetime >= ?', datetime)
    
    if snapshots_after.empty?
      raise "No snapshot for team (id: #{id}) exists after or at #{datetime}"
    end

    snapshots_after.order(datetime: :asc).limit(1).first.elo
  end

  def elo_before(datetime)
    if datetime.nil?
      raise "datetime is required"
    end

    snapshots_before = snapshots.where('datetime < ?', datetime)
    
    if snapshots_before.empty?
      raise "No snapshot for team (id: #{id}) exists before or at #{datetime}"
    end

    snapshots_before.order(datetime: :desc).limit(1).first.elo
  end

  def matches
    Match.where('opponent1_id = ? OR opponent2_id = ?', id, id)
  end

  private

  def last_snapshot
    snapshots.order(datetime: :asc).last
  end
end
