module NewSeeder
  class CreateLeagues
    def initialize(league_ids)
      @league_ids = league_ids
    end

    def self.call(league_ids)
      new(league_ids).call
    end

    def call
      league_ids.each do |league_id|
        league_data = fetch_league_data(league_id)
        PandaScore::League.find_or_initialize_by(panda_score_id: league_id)
          .update(data: league_data)
      end
    end

    private

    def fetch_league_data(league_id)
      PandaScore.league(id: league_id)
    end
  end
end