class AddTimestampsToModels < ActiveRecord::Migration[7.0]
  def change
    add_timestamps :leagues, default: -> { 'CURRENT_TIMESTAMP' }
    add_timestamps :series, default: -> { 'CURRENT_TIMESTAMP' }
    add_timestamps :tournaments, default: -> { 'CURRENT_TIMESTAMP' }
    add_timestamps :teams, default: -> { 'CURRENT_TIMESTAMP' }
    add_timestamps :matches, default: -> { 'CURRENT_TIMESTAMP' }
    add_timestamps :games, default: -> { 'CURRENT_TIMESTAMP' }
    add_timestamps :snapshots, default: -> { 'CURRENT_TIMESTAMP' }
    add_timestamps :teams_tournaments, default: -> { 'CURRENT_TIMESTAMP' }
  end
end
