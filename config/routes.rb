# frozen_string_literal: true

require 'sidekiq/web'

Rails.application.routes.draw do
  resources :series, only: %i[index show]

  root 'series#index'

  mount Sidekiq::Web => '/sidekiq'
end
