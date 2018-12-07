Rails.application.routes.draw do


  resources :roles
  namespace :invoices do
    resources :clients do
      get :autocomplete_document, on: :collection
    end
  end

  resources :notifications, only: :index
  resources :iva_books do
    get :generate_pdf, on: :collection
  end
  resources :purchase_invoices do
    get :autocomplete_arrival_note_id, on: :collection
    get :autocomplete_purchase_order, on: :collection
  end
  resources :arrival_notes do
    resources :arrival_note_details, shallow: true
    get :set_purchase_order, on: :collection
    get :generate_pdf, on: :member
    get :autocomplete_purchase_order, on: :collection
    patch :cancel, on: :member
  end

  resources :purchase_orders do
    resources :purchase_order_details, shallow: true
    get :autocomplete_product_code, :on => :collection
    get :set_supplier, on: :collection
    get :generate_pdf, on: :member
    patch :approve, on: :member
  end

  resources :products do
    get :autocomplete_product_code, :on => :collection
    get :export, on: :collection
    post :import, on: :collection
  end

  resources :services do
    get :autocomplete_product_code, :on => :collection
    get :export, on: :collection
    post :import, on: :collection
  end

  resources :users, only: [:index, :show] do
    get :autocomplete_company_code, :on => :collection
    patch :approve, on: :member
    patch :disapprove, on: :member
  end
  resources :suppliers
  resources :depots
  resources :receipts
  resources :clients
  resources :delivery_notes
  resources :product_categories
  resources :companies

  devise_for :users, :path_prefix => 'sessions', controllers: { registrations: 'users/registrations' }

  #CLIENTES
  # get   '/invoices/:invoice_id/client/', to: 'invoices/clients#show', as: 'invoice_client'
  # get   '/invoices/:invoice_id/client/edit', to: 'invoices/clients#edit', as: 'edit_invoice_client'
  # get   '/invoices/:invoice_id/client/edit', to: 'invoices/clients#edit', as: 'edit_invoice_client'
  # patch '/invoices/:invoice_id/client', to: 'invoices/clients#update'
  # post  '/invoices/:invoice_id/client/edit', to: 'invoices/clients#create'
  # get   '/invoices/:invoice_id/clients/autocomplete_document', to: 'invoices/clients#autocomplete_document', as: 'autocomplete_document_clients'
  #CLIENTES

  #ACCOUNT MOVEMENTS
  get '/clients/:id/account_movements', to: 'clients/account_movements#index', as: 'client_account_movements'
  #ACCOUNT MOVEMENTS


  resources :invoices do
    resources :invoice_details
    get :autocomplete_product_code, :on => :collection
    get :confirm, on: :member
    get :search_product, on: :collection
    get :autocomplete_associated_invoice, on: :collection
    get :change_attributes, on: :collection
    get :change_attributes, on: :member
    get :set_associated_invoice, on: :collection
    get :set_associated_invoice, on: :member
  end

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root "companies#new"

  get '/city/:city_id/get_localities' => 'application#get_localities', as: 'get_localities'
end
