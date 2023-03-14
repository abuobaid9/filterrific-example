Rails.application.routes.draw do
  devise_for :users
  resources :products do
    get :search, on: :collection
  end
  resources :categories
 root to:'users#index'
  resources :users
end
