Rails.application.routes.draw do


  resources :arrival_notes
  resources :delivery_notes
  resources :purchase_orders do
    resources :purchase_order_details, shallow: true
    get :autocomplete_product_code, :on => :collection
    get :set_supplier, on: :collection
    get :generate_pdf, on: :member
  end
  resources :suppliers
  resources :depots
  resources :receipts
  resources :clients
  resources :products do
    get :export, on: :collection
    get :import, on: :collection
  end
  resources :product_categories
  devise_for :users
  resources  :companies

  #CLIENTES
  get   '/invoices/:invoice_id/client/', to: 'invoices/clients#show', as: 'invoice_client'
  get   '/invoices/:invoice_id/client/edit', to: 'invoices/clients#edit', as: 'edit_invoice_client'
  patch '/invoices/:invoice_id/client', to: 'invoices/clients#update'
  post  '/invoices/:invoice_id/client/edit', to: 'invoices/clients#create'
  #CLIENTES

  #ACCOUNT MOVEMENTS
  get '/clients/:id/account_movements', to: 'clients/account_movements#index', as: 'client_account_movements'
  #ACCOUNT MOVEMENTS
  resources :invoices do
    resources :invoice_details
    get :autocomplete_product_code, :on => :collection
    get :confirm, on: :member
  end

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root "companies#new"

  get '/city/:city_id/get_localities' => 'application#get_localities', as: 'get_localities'
end
