snapshot = Snapshot.find(74080)
snapshot.update!(datetime: snapshot.serie.earliest_game_end - 1.hour)