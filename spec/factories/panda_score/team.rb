# frozen_string_literal: true

FactoryBot.define do
  factory :panda_score_team, class: "PandaScore::Team" do
    sequence(:panda_score_id) { |n| n }
    data { {} }
  end
end
