# frozen_string_literal: true

Rails.application.routes.draw do
  resources :leagues, only: %i[index show] do
    resources :series, only: [:show]
  end
  # resources :series, only: [:index, :show]
  root 'leagues#index'
end
