# frozen_string_literal: true

require 'sidekiq/web'

Rails.application.routes.draw do
  resources :series, only: %i[index show]

  get 'what-is-elo', to: 'static_pages#what_is_elo'
  get "seasons/:year/:league_id", to: "seasons#show", as: "season"
  
  Sidekiq::Web.use Rack::Auth::Basic do |username, password|
    ActiveSupport::SecurityUtils.secure_compare(::Digest::SHA256.hexdigest(username), ::Digest::SHA256.hexdigest(ENV["SIDEKIQ_USERNAME"])) &
      ActiveSupport::SecurityUtils.secure_compare(::Digest::SHA256.hexdigest(password), ::Digest::SHA256.hexdigest(ENV["SIDEKIQ_PASSWORD"]))
  end

  mount Sidekiq::Web => '/sidekiq'

  unless Rails.env.production?
    get "/colors", to: "colors#index"
    patch "/update_color", to: "colors#update_color"
  end

  root 'series#index'
end
