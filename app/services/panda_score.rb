class PandaScore
  def self.get_data_for(object)
    path = object_path(object)
    params = { "filter[id]": object.external_id }
    response = request(path: path, params: params)
    return response.first
  end

  private

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