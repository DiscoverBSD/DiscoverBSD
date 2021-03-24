Rails.application.routes.draw do
  root 'home#show'
  get 'home/show'
  resources :posts, only: [:new, :create] do
    get :by_day, on: :collection
  end
  get '/p/:slug', to: 'home#show', as: :post
  get '/feeds/posts/default', to: 'posts#feed'
  get '/auth/:provider/callback', to: 'sessions#create'
  resources :sessions, only: [:destroy]
  namespace :admin do
    resources :posts, only: [:update] do
      post :approve_and_tweet, on: :member
    end
    get 'dashboard/show'
    get 'newsletter/show'
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
