# frozen_string_literal: true

FactoryBot.define do
  factory :team do
    sequence(:panda_score_id) { |n| n }
    sequence(:acronym) { |n| "C#{n}" }
  end
end
