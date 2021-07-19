# frozen_string_literal: true

FactoryBot.define do
  factory :match do
    tournament
    opponent1 { team }
    opponent2 { team }
  end
end
