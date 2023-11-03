# frozen_string_literal: true

# This populates from the API into PandaScore objects
# This will take several hours with sidekiq, ideally is only run once.
# ThirdSeeder::Seed.call

# This populates application objects from the PandaScore objects
PandaScore::League.all.each do |league|
end

# This creates snapshots from the application objects
League.all.each do |league|
  League::CreateSnapshots.new(league).call
end
