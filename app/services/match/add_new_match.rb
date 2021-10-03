class Match
  class AddNewMatch
    def initialize(match_data)
      @match_data = match_data
    end

    def call
      raise "League does not exist" unless league
      return if match_exists?
      return unless valid_serie?

      find_or_create_serie
      find_or_create_tournament
      find_or_create_teams

      assign_match_to_tournament
      assign_teams_to_tournament

      create_games_for_match

      match
    end

    private

    attr_reader :match_data, :serie, :tournament

    def match
      @match ||= MatchFactory.new(match_data).call
    end

    def league
      @league ||= League.find_by(panda_score_id: match_data["league_id"])
    end


    def match_exists?
      Match.find_by(panda_score_id: match_data["id"])
    end

    def valid_serie?
      Serie.valid_name?(match_data["serie"]["full_name"])
    end

    def find_or_create_serie
      @serie ||= Serie.find_by(panda_score_id: match_data["serie_id"]) || begin
        serie = SerieFactory.new(match_data["serie"]).call
        league.series << serie
        serie
      end
    end

    def find_or_create_tournament
      @tournament ||= Tournament.find_by(panda_score_id: match_data["tournament_id"]) || begin
        tournament = TournamentFactory.new(match_data["tournament"]).call
        serie.tournaments << tournament
        tournament
      end
    end

    def find_or_create_teams
      match_data["teams"].each do |team_data|
        find_or_create_team(team_data)
      end
    end

    def find_or_create_team(team_data)
      Team.find_by(panda_score_id: team_data["id"]) || begin
        team = TeamFactory.new(team_data: team_data, serie: serie).call
        tournament.teams << team
        team
      end
    end

    def assign_match_to_tournament
      tournament.matches << match
    end

    def assign_teams_to_tournament
      match.teams.each do |team|
        unless tournament.teams.include?(team)
          tournament.teams << team
        end
      end
    end

    def create_games_for_match
      match_data["games"].each do |new_game|
        match.games << create_game(new_game)
      end
    end

    def create_game(game_data)
      GameFactory.new(game_data).call
    end
  end
end