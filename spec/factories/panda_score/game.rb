# frozen_string_literal: true

FactoryBot.define do
  factory :panda_score_game, class: "PandaScore::Game" do
    panda_score_id { 1 }
    data { {} }
  end
end
