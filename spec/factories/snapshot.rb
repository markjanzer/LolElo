# frozen_string_literal: true

FactoryBot.define do
  factory :snapshot do
    team
    serie
    elo { 1500 }
  end
end
