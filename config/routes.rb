Rails.application.routes.draw do
  resources :series, only: [:index, :show]
  root "series#index"
end
