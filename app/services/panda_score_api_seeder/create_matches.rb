module PandaScoreAPISeeder
  class CreateMatches
    def initialize(tournament)
      @tournament = tournament
    end

    def call
      match_ids = tournament.data["matches"].map { |m| m["id"] }
      panda_score_matches = PandaScore::Match.where(panda_score_id: match_ids)

      panda_score_matches.each do |ps_match|
        match = Match.find_or_initialize_by(panda_score_id: ps_match.data["id"])
        match.assign_attributes({
          end_at: ps_match.data["end_at"],
          opponent1: opponent1(ps_match),
          opponent2: opponent2(ps_match)
        })
        tournament.matches << match
      end
    end

    private

    attr_reader :tournament

    def opponent1(ps_match)
      Team.find_by(panda_score_id: ps_match.data["opponents"].first["opponent"]["id"])
    end

    def opponent2(ps_match)
      Team.find_by(panda_score_id: ps_match.data["opponents"].second["opponent"]["id"])
    end
  end
end