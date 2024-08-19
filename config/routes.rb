Rails.application.routes.draw do
  root "games#home"
  post "games/:id/:x/:y", to: "games#update", as: :reveal

  resources :games, only: [:index, :new, :show, :create] do
    collection do
      get :my
    end
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
end
