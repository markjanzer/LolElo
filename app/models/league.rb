class League < ApplicationRecord
  has_many :series, class_name: 'Serie'

  def self.panda_score_data(external_id)
    get_data(path: "/lol/leagues", params: { "filter[id]": external_id }).first
  end

  def self.find_data_by_name(name)
    get_data(path: "/lol/leagues", params: { "filter[name]": name }).first
  end
end
