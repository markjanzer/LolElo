Rails.application.routes.draw do
  get "/chart_data" => "application#chart_data"
  root "application#index"
end
