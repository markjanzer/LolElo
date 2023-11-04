# frozen_string_literal: true

FactoryBot.define do
  factory :panda_score_league, class: "PandaScore::League" do
    panda_score_id { 1 }
    data { {} }
  end
end
