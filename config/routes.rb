Rails.application.routes.draw do
  devise_for :users
  root to: 'cards#index'
  resources :cards, except: [:index, :show] do
    collection do
      post 'card_test'  # テストカードのみ可能
      post 'card_show'
      post 'card_delete'
      post 'card_default'
    end
  end
  resources :charges
  resources :plans
end
