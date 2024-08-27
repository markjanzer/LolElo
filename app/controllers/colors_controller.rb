# frozen_string_literal: true

class ColorsController < ApplicationController
  def index
    # Execute the SQL query
    results = ActiveRecord::Base.connection.execute(<<-SQL)
      SELECT teams.id, teams.name AS team_name, teams.color, teams.panda_score_id, 
             leagues.name AS league_name, MAX(matches.end_at) AS last_match_date
      FROM teams
      JOIN teams_tournaments ON teams_tournaments.team_id = teams.id
      JOIN tournaments ON teams_tournaments.tournament_id = tournaments.id
      JOIN series ON tournaments.serie_id = series.id
      JOIN leagues ON series.league_id = leagues.id
      JOIN matches ON matches.opponent1_id = teams.id OR matches.opponent2_id = teams.id
      GROUP BY teams.id, leagues.id
    SQL

    # Group results by league
    @teams_by_league = results.group_by { |row| row["league_name"] }.transform_values do |teams|
      teams.map do |team|
        {
          id: team["id"],
          name: team["team_name"],
          color: team["color"],
          panda_score_id: team["panda_score_id"],
          last_match_date: team["last_match_date"],
          custom_color: !Team::UNIQUE_COLORS.include?(team["color"])
        }
      end.sort do |team_a, team_b| 
        team_b[:last_match_date].to_date <=> team_a[:last_match_date].to_date
      end
    end
  end
  
  def update_color
    team = Team.find(params[:team_id])
    team.color = params[:color]
    team.save
 
    # Load json from /config/team_colors.json
    json = File.read(Rails.root.join('config', 'team_colors.json'))

    # Update the color for the team with the given id
    colors_hash = JSON.parse(json)
    colors_hash[team.panda_score_id.to_s] = team.color
    new_json = JSON.pretty_generate(colors_hash)
    
    # Save the updated json back to /config/team_colors.json
    File.open(Rails.root.join('config', 'team_colors.json'), 'w') { |file| file.write(new_json) }
    
    # Redirect to the team's page
    redirect_to colors_path
  end
end