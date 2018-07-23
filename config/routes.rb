Rails.application.routes.draw do
  root 'home#show'
  get 'home/show'
  resources :posts, only: [:new, :create] do
    get :by_day, on: :collection
  end
  get '/p/:slug', to: 'home#show', as: :post
  get '/auth/:provider/callback', to: 'sessions#create'
  resources :sessions, only: [:destroy]
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
