# frozen_string_literal: true

leagues_seed_data = [
  { abbreviation: "lcs", league_id: 4198, time_zone: 'America/Los_Angeles' },
  { abbreviation: "lec", league_id: 4197, time_zone: 'Europe/Berlin' },
  { abbreviation: "lck", league_id: 293, time_zone: "Asia/Seoul" },
  { abbreviation: "lpl", league_id: 294, time_zone: "Asia/Shanghai" },
]

SeedFromPandaScore.new(leagues_seed_data).call
League.all.each do |league|
  League::CreateSnapshots.new(league).call
end
