# frozen_string_literal: true
class Updater
  class AddNewMatches
    def initialize
    end

    def call
      League.all.each do |league|
        League::AddNewMatches.call(league)
      end
    end
  end
end