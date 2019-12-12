Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  get '/sync', to: 'sync#subscription_callback'
  post '/sync', to: 'sync#sync_activity'

  resources :users do
    get :success
  end

  root 'users#new'
end
