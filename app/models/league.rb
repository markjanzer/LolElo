class League < ApplicationRecord
  has_many :series, class_name: 'Serie'

  def self.pandascore_data(external_id)
    get_data(path: "/lol/leagues", params: { "filter[id]": external_id }).first
  end

  def self.find_data_by_name(name)
    get_data(path: "/lol/leagues", params: { "filter[name]": name }).first
  end

  def pandascore_data
    League.pandascore_data(external_id)
  end
end
