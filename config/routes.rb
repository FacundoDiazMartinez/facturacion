Rails.application.routes.draw do
  scope module: :accountant, path: "/accountant" do
    resources :daily_cashes do
      get :general_payments, on: :collection
    end
    resources :credit_cards do
      get :new_charge, on: :member
      post :charge, on: :member
    end
    resources :iva_books do
      collection do
        get :generate_pdf
        get :export
      end
    end
  end


  ### ALMACEN
  scope module: :warehouses, path: "/warehouses" do
    resources :home, as: :warehouses_home, only: :index
    resources :depots
    resources :arrival_notes do
      collection do
        get :set_purchase_order
        get :autocomplete_purchase_order
      end
      member do
        get :set_purchase_order
        get :generate_pdf
        patch :cancel
      end
    end
    resources :delivery_notes do
      get :autocomplete_client, on: :collection
      get :set_invoice, on: :collection
      get :generate_pdf, on: :member
      get :autocomplete_invoice, on: :collection
      get :search_product, on: :collection
      get :set_associated_invoice, on: :collection
      get :set_associated_invoice, on: :member
      patch :cancel, on: :member
    end
    namespace :delivery_notes do
      resources :clients do
        get :autocomplete_document, on: :collection
      end
    end
    resources :transfer_requests do
      patch :cancel, on: :member
      patch :receive_transfer, on: :member
      get :search_product, on: :collection
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
    resources :product_categories
  end

  ### COMPRAS
  scope module: :purchases, path: "/purchases" do
    resources :home, as: :purchases_home, only: :index
    resources :purchase_orders do
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
    resources :purchase_invoices do
      collection do
        get :autocomplete_arrival_note_id
        get :autocomplete_purchase_order
      end
    end
    resources :suppliers
  end

  ### PERSONAL
  scope module: :staff, path: "/staff" do
    resources :roles do
      resources :role_permissions do
        post :toggle_association, on: :collection
      end
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
  end

  ### VENTAS
  scope module: :sales, path: "/sales" do
    resources :home, as: :sales_home, only: :index
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
    resources :receipts do
      # resources :account_movements
      collection do
        get :autocomplete_invoice
        get :autocomplete_credit_note
        get :autocomplete_invoice_and_debit_note
        get :get_cr_card_fees
        get :get_fee_details
        get :associate_invoice
      end
    end
    namespace :receipts  do
      resources :clients do
        get :autocomplete_document, on: :collection
        get :autocomplete_name,     on: :collection
      end
    end
    resources :clients do
      resources :account_movements do
        get :export, on: :collection
      end
    end
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


  resources :daily_cash_movements



  resources :stadistics do
    collection do
      get :sales
      get :products
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

  resources :sended_advertisements do
  get :get_all_clients, on: :collection
  end

  resources :notifications, only: [:index, :show]
  resources :companies
  devise_for :users, :path_prefix => 'sessions', controllers: { registrations: 'users/registrations' }
  resources :income_payments

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root to: "companies#new"

  get '/city/:city_id/get_localities' => 'application#get_localities', as: 'get_localities'
end
