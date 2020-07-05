class LeagueFactory
  attr_reader :league_external_id, :league
  
  def initialize(league_external_id)
    @league_external_id = league_external_id
  end

  def call
    create_league
    create_series
  end

  def league_data
    league_data = League.pandascore_data(league_external_id)
  end

  def create_league
    @league = League.find_or_initialize_by(external_id: league_external_id)
    @league.name = league_data["name"]
    @league.save!
  end

  def create_series
    series_ids.each do |series_id|
      SerieFactory.new(series_id).call
    end
  end

  def series_ids
    league_data["series"].pluck("id")
  end
end