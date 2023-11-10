# frozen_string_literal: true

FactoryBot.define do
  factory :team do
    sequence(:panda_score_id) { |n| n }
  end
end
