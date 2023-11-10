module ApplicationSeeder
  class CreateOrUpdateMatch
    def initialize(panda_score_match)
      @panda_score_match = panda_score_match
    end

    def call
      match = Match.find_or_initialize_by(panda_score_id: panda_score_match.panda_score_id)
      match.update({
        end_at: panda_score_match.data["end_at"],
        opponent1: panda_score_match.opponent1,
        opponent2: panda_score_match.opponent2,
        tournament: panda_score_match.tournament
      })
    end

    private

    attr_reader :panda_score_match
  end
end