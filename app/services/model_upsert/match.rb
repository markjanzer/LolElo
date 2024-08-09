module ModelUpsert
  class Match
    def self.call(panda_score_match)
      new(panda_score_match).call
    end
    
    def initialize(panda_score_match)
      @panda_score_match = panda_score_match
    end

    def call
      return false if panda_score_match.tournament.nil? || panda_score_match.opponent1.nil? || panda_score_match.opponent2.nil?
      return if reject?

      ::Match.find_or_initialize_by(panda_score_id: panda_score_match.panda_score_id)
        .update!({
          end_at: panda_score_match.data["end_at"],
          opponent1: panda_score_match.opponent1,
          opponent2: panda_score_match.opponent2,
          tournament: panda_score_match.tournament
        })
    end

    private

    attr_reader :panda_score_match

    def reject?
      panda_score_match.data["forfeit"] || panda_score_match.data["end_at"].nil?
    end
  end
end