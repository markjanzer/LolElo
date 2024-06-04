# frozen_string_literal: true

FactoryBot.define do
  factory :panda_score_serie, class: "PandaScore::Serie" do
    sequence(:panda_score_id) { |n| n }
    data { {
      "tournaments": [{}]
    } }
  end
end
