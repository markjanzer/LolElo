class PandaScoreAPISeeder
  LEAGUE_IDS = [
    4198, # LCS 
    4197, # LEC
    293,  # LCK
    294   # LPL
  ]
  
  def initialize(league_ids = LEAGUE_IDS)
    @league_ids = league_ids
  end
  
  def self.call(*)
    new(*).call
  end

  def call
    league_ids.each do |league_id|
      ::Seed::CreateLeagueJob.perform_async(league_id)
    end
  end

  private

  attr_reader :league_ids
end