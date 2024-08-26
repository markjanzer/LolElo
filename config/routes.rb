# frozen_string_literal: true

require 'sidekiq/web'

Rails.application.routes.draw do
  resources :series, only: %i[index show]

  root 'series#index'

  get 'what-is-elo', to: 'static_pages#what_is_elo'

  Sidekiq::Web.use Rack::Auth::Basic do |username, password|
    ActiveSupport::SecurityUtils.secure_compare(::Digest::SHA256.hexdigest(username), ::Digest::SHA256.hexdigest(ENV["SIDEKIQ_USERNAME"])) &
      ActiveSupport::SecurityUtils.secure_compare(::Digest::SHA256.hexdigest(password), ::Digest::SHA256.hexdigest(ENV["SIDEKIQ_PASSWORD"]))
  end
  mount Sidekiq::Web => '/sidekiq'
end
