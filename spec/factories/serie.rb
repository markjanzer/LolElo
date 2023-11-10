# frozen_string_literal: true

FactoryBot.define do
  factory :serie do
    sequence(:panda_score_id) { |n| n }
    league
  end
end
