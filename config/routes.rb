Rails.application.routes.draw do
  resources :invoices
  devise_for :users
  resources  :companies
  resources  :clients, only: [:new, :edit, :index]
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root "companies#new"

  get '/city/:city_id/get_localities' => 'application#get_localities', as: 'get_localities'
end
