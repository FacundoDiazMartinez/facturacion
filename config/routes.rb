Rails.application.routes.draw do

  resources :products
  resources :product_categories
  devise_for :users
  resources  :companies
  resources :invoices do
    resource :client
    resources :invoice_details
    get :autocomplete_product_code, :on => :collection
    get :confirm, on: :member
  end

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root "companies#new"

  get '/city/:city_id/get_localities' => 'application#get_localities', as: 'get_localities'
end
