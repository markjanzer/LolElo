class League
  class AddNewMatches
    def initialize(league)
      @league = league
    end

    def call
      panda_score_new_matches.each do |match_data|
        Match::AddNewMatch.new(match_data).call
      end
    end

    private

    attr_reader :league

    def last_match_end_at
      Match.order(:end_at).last.end_at
    end

    def panda_score_new_matches
      # Might need to deal with pagination here.
      @panda_score_new_matches ||= PandaScore.request(
        path: 'matches',
        params: {
          "filter[league_id]": league.panda_score_id,
          "range[end_at]": "#{last_match_end_at.iso8601},#{DateTime.current.iso8601}"
        }
      )
    end
  end
end