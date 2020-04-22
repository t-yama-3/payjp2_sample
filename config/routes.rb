Rails.application.routes.draw do
  devise_for :users
  root to: 'cards#index'
  resources :cards, except: [:index] do
    collection do
      post 'card_delete'
    end
  end
end
