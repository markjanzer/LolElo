# frozen_string_literal: true

FactoryBot.define do
  factory :panda_score_match, class: "PandaScore::Match" do
    sequence(:panda_score_id) { |n| n }
    data { {} }
  end
end
