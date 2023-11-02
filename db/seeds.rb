# frozen_string_literal: true

# This will need to be ran multiple times
result = NewSeeder::SeedFromPandaScore.new.call

if result == "Done!"
  League.all.each do |league|
    League::CreateSnapshots.new(league).call
  end
end
