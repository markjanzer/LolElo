module ApplicationSeeder
  class CreateOrUpdateMatch
    def initialize(panda_score_match)
      @panda_score_match = panda_score_match
    end

    def call
      match = Match.find_or_initialize_by(panda_score_id: panda_score_match.panda_score_id)
      match.update({
        end_at: panda_score_match.data["end_at"],
        opponent1: opponent1(panda_score_match),
        opponent2: opponent2(panda_score_match),
        tournament: tournament
      })
    end

    private

    attr_reader :tournament

    def opponent1(panda_score_match)
      Team.find_by(panda_score_id: panda_score_match.data["opponents"].first["opponent"]["id"])
    end

    def opponent2(panda_score_match)
      Team.find_by(panda_score_id: panda_score_match.data["opponents"].second["opponent"]["id"])
    end

    def tournament
      Tournament.find_by(panda_score_id: panda_score_match.data["tournament_id"])
    end
  end
end