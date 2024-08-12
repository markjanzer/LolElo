snapshot = Snapshot.find(74080)
snapshot.update!(datetime: snapshot.serie.unofficial_begin_at - 1.hour)