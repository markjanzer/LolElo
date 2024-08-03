class UpdateTracker < ApplicationRecord
  enum update_type: { api: "api", model: "model" }, _prefix: true
  
  def self.record_api_update
    create(completed_at: Time.current, update_type: :api)
  end

  def self.record_model_update
    create(completed_at: Time.current, update_type: :model)
  end

  def self.last_api_update
    where(update_type: :api)
      .where.not(completed_at: nil)
      .order(completed_at: :desc)
      .first&.completed_at || Time.at(0)
  end

  def self.last_model_update
    where(update_type: :model)
      .where.not(completed_at: nil)
      .order(completed_at: :desc)
      .first&.completed_at || Time.at(0)
  end
end