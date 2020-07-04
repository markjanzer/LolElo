Rails.application.routes.draw do
  resources :leagues, only: [:index, :show] do
    resources :series, only: [:show]
  end
  # resources :series, only: [:index, :show]
  root "leagues#index"
end
