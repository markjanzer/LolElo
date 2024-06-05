# frozen_string_literal: true

FactoryBot.define do
  factory :panda_score_tournament, class: "PandaScore::Tournament" do
    sequence(:panda_score_id) { |n| n }
    data { {
      "teams": [],
      "matches": []
    } }
  end
end
