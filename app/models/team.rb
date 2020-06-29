class Team < ApplicationRecord
  has_many :snapshots
  
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

  private

  def last_snapshot
    snapshots.order(:date).last
  end
end
