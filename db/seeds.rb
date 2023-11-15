# frozen_string_literal: true

# This populates from the API into PandaScore objects
# This will take several hours with sidekiq, ideally is only run once.
# PandaScoreAPISeeder::Seed.call

# This populates application objects from the PandaScore objects
PandaScore::League.all.each do |league|
end

# This creates snapshots from the application objects
Snapshot::Creator.call
