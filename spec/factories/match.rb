# frozen_string_literal: true

FactoryBot.define do
  factory :match do
    tournament
    association :opponent1, factory: :team
    association :opponent2, factory: :team
    end_at { Time.now }
  end
end
