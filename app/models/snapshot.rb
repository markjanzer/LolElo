# frozen_string_literal: true

class Snapshot < ApplicationRecord
  belongs_to :game, optional: true
  belongs_to :team
end
