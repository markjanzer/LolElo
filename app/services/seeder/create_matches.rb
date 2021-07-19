class Seeder
  class CreateMatches
    def initialize(tournament)
      @tournament = tournament
    end

    def call
      matches_data.each do |match_data|
        tournament.matches << new_match(match_data)
      end
    end

    private

    attr_reader :tournament

    def matches_data
      @matches_data ||= PandaScore.matches(tournament_id: tournament.external_id)
    end

    def new_match(match_data)
      MatchFactory.new(match_data).call
    end
  end
end