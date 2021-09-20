class Match
  class AddNewMatch
    def initialize(match_data)
      @match_data = match_data
    end

    def call
      # {"name"=>"EDG vs WE", "detailed_stats"=>true, "tournament_id"=>6159, "official_stream_url"=>"https://www.douyu.com/topic/LPLXJS?rid=424559", "begin_at"=>"2021-07-24T11:17:11Z", "live"=>{"opens_at"=>"2021-07-24T11:02:11Z", "supported"=>true, "url"=>"wss://live.pandascore.co/matches/595811"}, "end_at"=>"2021-07-24T12:46:52Z", "games"=>[{"begin_at"=>"2021-07-24T11:17:12Z", "complete"=>true, "detailed_stats"=>true, "end_at"=>"2021-07-24T11:51:27Z", "finished"=>true, "forfeit"=>false, "id"=>225293, "length"=>1672, "match_id"=>595811, "position"=>1, "status"=>"finished", "video_url"=>nil, "winner"=>{"id"=>2574, "type"=>"Team"}, "winner_type"=>"Team"}, {"begin_at"=>"2021-07-24T12:06:57Z", "complete"=>true, "detailed_stats"=>true, "end_at"=>"2021-07-24T12:46:53Z", "finished"=>true, "forfeit"=>false, "id"=>225294, "length"=>1960, "match_id"=>595811, "position"=>2, "status"=>"finished", "video_url"=>nil, "winner"=>{"id"=>2574, "type"=>"Team"}, "winner_type"=>"Team"}], "serie_id"=>3660, "videogame"=>{"id"=>1, "name"=>"LoL", "slug"=>"league-of-legends"}, "live_embed_url"=>nil, "match_type"=>"best_of", "streams_list"=>[{"embed_url"=>nil, "language"=>"zh", "main"=>true, "official"=>true, "raw_url"=>"https://www.douyu.com/topic/LPLXJS?rid=424559"}, {"embed_url"=>nil, "language"=>"zh", "main"=>false, "official"=>true, "raw_url"=>"https://lpl.qq.com/es/live.shtml?bgid=148&bmid=7997"}, {"embed_url"=>"https://player.twitch.tv/?channel=lpl", "language"=>"en", "main"=>false, "official"=>true, "raw_url"=>"https://www.twitch.tv/lpl"}], "original_scheduled_at"=>"2021-07-24T11:00:00Z", "status"=>"finished", "league"=>{"id"=>294, "image_url"=>"https://cdn.pandascore.co/images/league/image/294/220px-LPL_2020.png", "modified_at"=>"2020-06-02T08:53:12Z", "name"=>"LPL", "slug"=>"league-of-legends-lpl-china", "url"=>"http://www.lolesports.com/en_US/lpl-china"}, "scheduled_at"=>"2021-07-24T11:00:00Z", "rescheduled"=>false, "draw"=>false, "id"=>595811, "slug"=>"edward-gaming-vs-team-we-2021-07-24", "modified_at"=>"2021-07-24T12:53:41Z", "tournament"=>{"begin_at"=>"2021-06-07T09:00:00Z", "end_at"=>nil, "id"=>6159, "league_id"=>294, "live_supported"=>true, "modified_at"=>"2021-07-18T09:33:40Z", "name"=>"Regular season", "prizepool"=>nil, "serie_id"=>3660, "slug"=>"league-of-legends-lpl-china-summer-2021-regular-season", "winner_id"=>nil, "winner_type"=>"Team"}, "winner"=>{"acronym"=>"WE", "id"=>2574, "image_url"=>"https://cdn.pandascore.co/images/team/image/2574/300px-Team_WElogo_square.png", "location"=>"CN", "modified_at"=>"2021-06-06T09:53:09Z", "name"=>"Team WE", "slug"=>"we"}, "number_of_games"=>3, "videogame_version"=>{"current"=>false, "name"=>"11.13.1"}, "streams"=>{"english"=>{"embed_url"=>"https://player.twitch.tv/?channel=lpl", "raw_url"=>"https://www.twitch.tv/lpl"}, "official"=>{"embed_url"=>nil, "raw_url"=>"https://www.douyu.com/topic/LPLXJS?rid=424559"}, "russian"=>{"embed_url"=>nil, "raw_url"=>nil}}, "serie"=>{"begin_at"=>"2021-06-07T09:00:00Z", "description"=>nil, "end_at"=>nil, "full_name"=>"Summer 2021", "id"=>3660, "league_id"=>294, "modified_at"=>"2021-05-31T10:05:38Z", "name"=>nil, "season"=>"Summer", "slug"=>"league-of-legends-lpl-china-summer-2021", "tier"=>"a", "winner_id"=>nil, "winner_type"=>nil, "year"=>2021}, "league_id"=>294, "winner_id"=>2574, "opponents"=>[{"opponent"=>{"acronym"=>"EDG", "id"=>405, "image_url"=>"https://cdn.pandascore.co/images/team/image/405/edward-gaming-52bsed1a.png", "location"=>"CN", "modified_at"=>"2021-06-06T09:48:15Z", "name"=>"EDward Gaming", "slug"=>"edward-gaming"}, "type"=>"Team"}, {"opponent"=>{"acronym"=>"WE", "id"=>2574, "image_url"=>"https://cdn.pandascore.co/images/team/image/2574/300px-Team_WElogo_square.png", "location"=>"CN", "modified_at"=>"2021-06-06T09:53:09Z", "name"=>"Team WE", "slug"=>"we"}, "type"=>"Team"}], "forfeit"=>false, "results"=>[{"score"=>0, "team_id"=>405}, {"score"=>2, "team_id"=>2574}], "game_advantage"=>nil}

      puts league
      raise "League does not exist" unless league
      return if match_exists?
      return unless valid_serie?

      # Do I need these?
      # Also this feels too implicit. I think I should explictly create
      # them if they don't exist
      serie
      tournament

      match = MatchFactory.new(match_data).call
      tournament.matches << match

      # Create the games for the match
      match_data["games"].each do |new_game|
        match.games << create_game(new_game)
      end

      match
    end

    private

    attr_reader :match_data

    def valid_serie?
      Serie.valid_name?(match_data["serie"]["full_name"])
    end

    def match_exists?
      Match.find_by(panda_score_id: match_data["id"])
    end

    def league
      @league ||= League.find_by(panda_score_id: match_data["league_id"])
    end

    def tournament
      @tournament ||= Tournament.find_by(panda_score_id: match_data["tournament_id"]) || begin
        tournament = TournamentFactory.new(match_data["tournament"]).call
        serie.tournaments << tournament

        match_data["teams"].each do |team_data|
          tournament.teams << find_or_create_team(team_data)
        end

        tournament
      end
    end

    def find_or_create_team(team_data)
      Team.find_by(panda_score_id: team_data["id"]) || begin
        team = TeamFactory.new(team_data).call
        team.save
        team
      end
    end

    def serie
      @serie ||= Serie.find_by(panda_score_id: match_data["serie_id"]) || begin
        serie = SerieFactory.new(match_data["serie"]).call
        league.series << serie
        serie
      end
    end

    def create_game(game_data)
      GameFactory.new(game_data).call
    end
  end
end