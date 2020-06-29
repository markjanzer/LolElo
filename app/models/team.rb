class Team < ApplicationRecord
  has_many :snapshots
  
  def elo
    return nil if last_snapshot.nil?
    last_snapshot.elo
  end

  private

  def last_snapshot
    snapshots.order(:date).last
  end
end
