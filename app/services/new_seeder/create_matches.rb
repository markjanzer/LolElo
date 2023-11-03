module NewSeeder
  class CreateMatches
    def self.call
      new.call
    end

    def call
      PandaScore::Tournament.all.each do |tournament|
        fetch_matches(tournament.panda_score_id).each do |match|
          match_data = match_data(match["id"])
          PandaScore::Match.find_or_initialize_by(panda_score_id: match["id"])
            .update(data: match_data)
        end
      end
    end

    private

    def fetch_matches(tournament_id)
      PandaScoreAPI.matches(tournament_id: tournament_id)
    end

    def fetch_match_data(match_id)
      PandaScoreAPI.match(id: match_id)
    end
  end
end