# frozen_string_literal: true

FactoryBot.define do
  factory :match do
    tournament
    opponent_1 { team }
    opponent_2 { team }
  end
end
