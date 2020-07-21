# lcs = LeagueFactory.new(league_id: 4198, time_zone: "America/Los_Angeles").call
# lec = LeagueFactory.new(league_id: 4197, time_zone: "Europe/Berlin").call
# lck = LeagueFactory.new(league_id: 293, time_zone: "Asia/Seoul").call
# lpl = LeagueFactory.new(league_id: 294, time_zone: "Asia/Shanghai" ).call

Snapshot.transaction do
  League.all.each do |league|
    SnapshotFactory.new(league).call
  end
end