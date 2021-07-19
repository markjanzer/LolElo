# frozen_string_literal: true

class League < ApplicationRecord
  has_many :series, class_name: 'Serie'
end
