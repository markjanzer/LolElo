require_relative '../../../config/environment'

serie = Serie.find(211)
serie.teams.each do |t| 
  first_snapshot = t.snapshots.order(datetime: :asc).first
  if first_snapshot.datetime > serie.earliest_game_end
    if first_snapshot.serie != serie
      raise "First snapshot for team #{t.name} does not belong to the serie"
    else
      first_snapshot.update(datetime: serie.earliest_game_end - 1.minute)
    end
  end
end