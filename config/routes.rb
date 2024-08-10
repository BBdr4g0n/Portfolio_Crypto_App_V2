Rails.application.routes.draw do
  resources :transactions
  resources :wallets
  resources :users, execpt: [:new]
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  root 'pages#home'

  get "signup", to: "users#new"

  get "login", to: "sessions#new"
  post "login", to: "sessions#create"
  delete "logout", to: "sessions#destroy"

  get 'upload', to: 'transactions#upload'
  post 'import', to: 'transactions#import'

  get 'dashboard', to: 'dashboard#index'
  get 'fetch_dashboard_data', to: 'dashboard#fetch_dashboard_data'
  get 'fetch_chart_data', to: 'dashboard#fetch_chart_data'

  get 'tokens/infos/:symbol', to: 'tokens#show_token_infos'
  get 'tokens/list', to: 'tokens#list_tokens'
end
