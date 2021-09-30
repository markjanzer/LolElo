# frozen_string_literal: true

class League < ApplicationRecord
  has_many :series, class_name: 'Serie'

  # I don't think we really need this but I couldn't figure out
  # the legit way to do this in League::CreateSnapshots
  has_many :tournaments, through: :series
  has_many :matches, through: :tournaments
  has_many :games, through: :matches

  has_many :snapshots, through: :series
end
