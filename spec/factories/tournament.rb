# frozen_string_literal: true

FactoryBot.define do
  factory :tournament do
    sequence(:panda_score_id) { |n| n }
    serie
  end
end
