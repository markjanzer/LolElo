serie_id = 231
snapshots = Snapshot.joins(game: { match: { tournament: :serie } }).where(series: { id: serie_id})
snapshots.update_all(serie_id: serie_id)