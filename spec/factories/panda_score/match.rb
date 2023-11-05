# frozen_string_literal: true

FactoryBot.define do
  factory :panda_score_match, class: "PandaScore::Match" do
    panda_score_id { 1 }
    data { {} }
  end
end
