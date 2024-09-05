require_relative '../../config/environment'

sql = <<-SQL
  SELECT AVG(ABS(snapshots.elo - snapshots.previous_elo)) as avg
  FROM snapshots
  WHERE snapshots.previous_elo IS NOT NULL;
SQL

puts ActiveRecord::Base.connection.execute(sql).first&.[]('avg')