# frozen_string_literal: true

# Not used right now, might use in near future
class InvalidMatchesCorrector
  def initialize(matches_data:, correct_matches_data: data_from_json_file)
    @matches_data = matches_data
    @correct_matches_data = correct_matches_data
  end

  def call
    matches_data.map do |match_data|
      match_data.merge(correct_match_data(match_data["id"]))
    end
  end

  private

  attr_reader :matches_data, :correct_matches_data

  def data_from_json_file
    file = File.read('./lib/assets/faulty_panda_score_match_data.json')
    JSON.parse(file)
  end

  def correct_match_data(match_id)
    correct_matches_data.find { |m| m["id"] == match_id } || {}
  end
end
