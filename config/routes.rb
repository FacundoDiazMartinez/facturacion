Rails.application.routes.draw do

  ### VENTAS
  scope module: :sales, path: "/sales" do
    resources :home, as: :sales_home
    resources :invoices do
      resources :invoice_details
      collection do
        get :autocomplete_product_code
        get :search_product
        get :autocomplete_associated_invoice
        get :autocomplete_invoice_number
        get :change_attributes
        get :set_associated_invoice
        get :get_total_payed_and_left
        get :sales_per_month
        get :sales_per_year
        get :states_per_month
        get :amount_per_month
        get :commissioner_per_month
        post :calculate_invoice_totals
      end
      member do
        get :confirm
        get :cancel
        get :change_attributes
        get :set_associated_invoice
        get :deliver
        get :paid_invoice_with_debt
        get :get_associated_invoice_details
      end
    end
    namespace :invoices do
      resources :clients do
        get :autocomplete_document, on: :collection
        get :autocomplete_name,     on: :collection
      end
    end
    resources :budgets do
      collection do
        get :autocomplete_client
        get :autocomplete_product_code
        get :search_product
      end
      member do
        patch :confirm
        patch :cancel
      end
    end
    namespace :budgets do
      resources :clients do
        get :autocomplete_document, on: :collection
      end
    end
  end

  resources :transfer_requests do
    patch :cancel, on: :member
    patch :receive_transfer, on: :member
    get :search_product, on: :collection
  end
  resources :credit_cards do
    get :new_charge, on: :member
    post :charge, on: :member
  end

  resources :banks do
    get :new_extraction, on: :member
    post :extract, on: :member
  end
  resources :advertisements do
    patch :cancel, on: :member
    patch :send_email, on: :member
  end
  resources :payments, only: :destroy
  resources :sales_files, only: [:index, :show]
  resources :price_changes do
    member do
      get :apply
    end
  end


  get 'daily_cash_movements/show'

  resources :daily_cashes do
    get :general_payments, on: :collection
  end
  resources :daily_cash_movements
  resources :roles do
    resources :role_permissions do
      post :toggle_association, on: :collection
    end
  end



  resources :stadistics do
    collection do
      get :sales
      get :products
    end
  end

  resources :receipts do
    resources :account_movements
    get :autocomplete_invoice, on: :collection
    get :autocomplete_credit_note, on: :collection
    get :autocomplete_invoice_and_debit_note, on: :collection
    get :get_cr_card_fees, on: :collection
    get :get_fee_details, on: :collection
    get :associate_invoice, on: :collection
  end


  namespace :receipts  do
    resources :clients do
      get :autocomplete_document, on: :collection
      get :autocomplete_name,     on: :collection
    end
  end

  namespace :payments do
    resources :payments
    resources :card_payments
    resources :cash_payments
    resources :retention_payments
    resources :debit_payments
    resources :bank_payments
    resources :debit_payments
    resources :cheque_payments do
      get :new_charge, on: :member
      post :charge, on: :member
    end
    resources :account_payments
    resources :compensation_payments
  end

  namespace :delivery_notes do
    resources :clients do
      get :autocomplete_document, on: :collection
    end
  end

  resources :sended_advertisements do
  get :get_all_clients, on: :collection
  end

  resources :notifications, only: [:index, :show]
  resources :iva_books do
    collection do
      get :generate_pdf
      get :export
    end
  end
  resources :purchase_invoices do
    get :autocomplete_arrival_note_id, on: :collection
    get :autocomplete_purchase_order, on: :collection
  end
  resources :arrival_notes do
    resources :arrival_note_details, shallow: true
    get :set_purchase_order, on: :collection
    get :set_purchase_order, on: :member
    get :generate_pdf, on: :member
    get :autocomplete_purchase_order, on: :collection
    patch :cancel, on: :member
  end

  resources :delivery_notes do
    get :autocomplete_client, on: :collection
    resources :delivery_note_details, shallow: true
    get :set_invoice, on: :collection
    get :generate_pdf, on: :member
    get :autocomplete_invoice, on: :collection
    patch :cancel, on: :member
    get :search_product, on: :collection
    get :set_associated_invoice, on: :collection
    get :set_associated_invoice, on: :member
  end

  resources :purchase_orders do
    resources :purchase_order_details, shallow: true
    collection do
      get :autocomplete_product_code
      get :set_supplier
      get :search_product
    end
    member do
      get :cancel
      post :deliver
    end
  end

  resources :products do
    resources :stocks, only: [:edit, :update]
    collection do
      get :autocomplete_product_code
      get :export
      get :product_category
      get :edit_multiple
      put :update_multiple
      post :import
      get :top_ten_products_per_month
      get :top_ten_products_per_year
      get :top_ten_sales_per_month
    end
    member do
      get :get_depots
    end
  end

  resources :services do
    get :autocomplete_product_code, :on => :collection
    get :export, on: :collection
    post :import, on: :collection
  end

  resources :users, only: [:index, :show, :update, :destroy] do
    get :autocomplete_company_code, :on => :collection
    patch :approve, on: :member
    patch :disapprove, on: :member
    get :roles, on: :member
    get :commission, on: :member
    get :edit_commission, on: :member
    patch :update_commission, on: :member
  end
  resources :suppliers
  resources :depots

  resources :clients do
    resources :account_movements do
      get :export, on: :collection
    end
  end

  resources :product_categories
  resources :companies

  devise_for :users, :path_prefix => 'sessions', controllers: { registrations: 'users/registrations' }

  resources :income_payments

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root "companies#new"

  get '/city/:city_id/get_localities' => 'application#get_localities', as: 'get_localities'
end
