class League
  class AddNewMatches
    def initialize(league)
      @league = league
    end

    def call
      new_matches_data.each do |match_data|
        Match::AddNewMatch.new(match_data).call
      end
    end

    private

    attr_reader :league

    def last_match_end_at
      Match.order(:end_at).last.end_at
    end

    def new_matches_data_from_panda_score
      # Might need to deal with pagination here.
      PandaScore.request(
        path: 'matches',
        params: {
          "filter[league_id]": league.panda_score_id,
          "range[end_at]": "#{last_match_end_at.iso8601},#{DateTime.current.iso8601}"
        }
      )
    end

    def new_matches_data
      @new_matches_data = InvalidMatchesCorrector.new(match_data: new_matches_data_from_panda_score).call
    end
  end
end