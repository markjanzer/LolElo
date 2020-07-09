# lcs = LeagueFactory.new(4198).call
# lec = LeagueFactory.new(4197).call
# lck = LeagueFactory.new(293).call
lpl = LeagueFactory.new(294).call

Snapshot.transaction do
  League.all.each do |league|
    SnapshotFactory.new(league).call
  end
end