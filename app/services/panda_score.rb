class PandaScore
  def self.get_data_for(object)
    path = object_path(object)
    get_data(path: path, id: object.external_id)
  end

  def self.league_data(id)
    get_data(path: "leagues", id: id)
  end

  private

  def self.get_data(path:, id:)
    params = { "filter[id]": id }
    response = request(path: path, params: params)
    return response.first
  end

  def self.object_path(object)
    object.class.name.downcase.pluralize
  end

  def self.request(path: "", params: {})
    response = HTTParty.get(
      'http://api.pandascore.co/lol/' + path, 
      query: params.merge({ "token" => ENV["panda_score_key"] })
    )
    JSON.parse(response.body)
  end

  # def set_path(object)
  #   case object
  #   when "leagues"
  #     @path = "leagues"
  #   when "series"
  #     @path = "series"
  #   when "tournaments"
  #     @path = "tournaments"
  #   when "matches"
  #     @path = "matches"
  #   when "past matches"
  #     @path = "matches/past"
  #   else
  #     raise "Not a valid path"
  #   end
  # end
end

# Maybe I should be documenting the different ways I'm going to want to get this data.