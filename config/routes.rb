# frozen_string_literal: true

require 'sidekiq/web'

Rails.application.routes.draw do
  resources :leagues, only: %i[index show] do
    resources :series, only: [:show]
  end

  # resources :series, only: [:index, :show]
  root 'leagues#index'

  # For basic HTTP auth (consider a more secure approach for production environments):
  # Sidekiq::Web.use(Rack::Auth::Basic) do |user, password|
  #   # Protect your Sidekiq Web UI with a username and password
  #   [user, password] == ["admin", "password"]
  # end

  mount Sidekiq::Web => '/sidekiq'
end
