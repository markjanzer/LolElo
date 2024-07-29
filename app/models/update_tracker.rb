class UpdateTracker < ApplicationRecord
  def self.record_update
    create(completed_at: Time.current)
  end

  def self.last_run_time
    order(completed_at: :desc).first&.completed_at || Time.at(0)
  end

  def self.second_to_last_run_time
    order(completed_at: :desc).second&.completed_at || Time.at(0)
  end
end