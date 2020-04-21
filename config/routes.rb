Rails.application.routes.draw do
  devise_for :users
  root to: 'cards#index'
  resources :cards, only: [:new, :create, :show, :destroy]
end
