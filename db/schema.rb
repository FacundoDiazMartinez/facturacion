# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2018_11_27_150729) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "account_movements", force: :cascade do |t|
    t.bigint "client_id"
    t.bigint "invoice_id"
    t.bigint "receipt_id"
    t.integer "days"
    t.string "cbte_tipo", null: false
    t.boolean "debe"
    t.boolean "haber"
    t.boolean "active", default: true, null: false
    t.float "total", default: 0.0, null: false
    t.float "saldo", default: 0.0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["client_id"], name: "index_account_movements_on_client_id"
    t.index ["invoice_id"], name: "index_account_movements_on_invoice_id"
    t.index ["receipt_id"], name: "index_account_movements_on_receipt_id"
  end

  create_table "arrival_note_details", force: :cascade do |t|
    t.bigint "arrival_note_id"
    t.bigint "product_id"
    t.string "quantity"
    t.boolean "cumpliment"
    t.string "observation"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["arrival_note_id"], name: "index_arrival_note_details_on_arrival_note_id"
    t.index ["product_id"], name: "index_arrival_note_details_on_product_id"
  end

  create_table "arrival_notes", force: :cascade do |t|
    t.bigint "company_id"
    t.bigint "purchase_order_id"
    t.bigint "user_id"
    t.bigint "depot_id"
    t.integer "number", null: false
    t.boolean "active", default: true, null: false
    t.string "state", default: "Pendiente", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_arrival_notes_on_company_id"
    t.index ["depot_id"], name: "index_arrival_notes_on_depot_id"
    t.index ["purchase_order_id"], name: "index_arrival_notes_on_purchase_order_id"
    t.index ["user_id"], name: "index_arrival_notes_on_user_id"
  end

  create_table "clients", force: :cascade do |t|
    t.string "name", null: false
    t.string "phone"
    t.string "mobile_phone"
    t.string "email"
    t.string "address"
    t.string "document_type", default: "D.N.I.", null: false
    t.string "document_number", null: false
    t.string "birthday"
    t.boolean "active", default: true, null: false
    t.string "iva_cond", default: "Responsable Monotributo", null: false
    t.bigint "company_id"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "saldo", default: 0.0, null: false
    t.index ["company_id"], name: "index_clients_on_company_id"
    t.index ["user_id"], name: "index_clients_on_user_id"
  end

  create_table "companies", force: :cascade do |t|
    t.string "email", null: false
    t.string "code", null: false
    t.string "name", null: false
    t.string "logo"
    t.string "address"
    t.string "society_name"
    t.string "cuit", null: false
    t.string "concepto", null: false
    t.string "moneda", default: "PES", null: false
    t.string "iva_cond", null: false
    t.string "country", default: "Argentina", null: false
    t.string "postal_code"
    t.date "activity_init_date"
    t.string "contact_number"
    t.string "environment", default: "testing", null: false
    t.string "cbu"
    t.boolean "paid", default: false, null: false
    t.string "suscription_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "province_id", null: false
    t.bigint "locality_id", null: false
    t.index ["locality_id"], name: "index_companies_on_locality_id"
    t.index ["province_id"], name: "index_companies_on_province_id"
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer "priority", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.bigint "payment_id"
    t.index ["payment_id"], name: "index_delayed_jobs_on_payment_id"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "delivery_notes", force: :cascade do |t|
    t.bigint "company_id"
    t.bigint "invoice_id"
    t.bigint "user_id"
    t.bigint "client_id"
    t.integer "number", null: false
    t.boolean "active", default: true, null: false
    t.string "state", default: "Pendiente", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["client_id"], name: "index_delivery_notes_on_client_id"
    t.index ["company_id"], name: "index_delivery_notes_on_company_id"
    t.index ["invoice_id"], name: "index_delivery_notes_on_invoice_id"
    t.index ["user_id"], name: "index_delivery_notes_on_user_id"
  end

  create_table "depots", force: :cascade do |t|
    t.string "name"
    t.boolean "active", default: true, null: false
    t.bigint "company_id"
    t.float "stock_count", default: 0.0, null: false
    t.boolean "filled", default: false, null: false
    t.string "location", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_depots_on_company_id"
  end

  create_table "friendly_names", force: :cascade do |t|
    t.string "name"
    t.string "subject_class"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "invoice_details", force: :cascade do |t|
    t.bigint "invoice_id"
    t.bigint "product_id"
    t.float "quantity", default: 1.0, null: false
    t.string "measurement_unit", null: false
    t.float "price_per_unit", default: 0.0, null: false
    t.float "bonus_percentage", default: 0.0, null: false
    t.float "bonus_amount", default: 0.0, null: false
    t.float "subtotal", default: 0.0, null: false
    t.string "iva_aliquot"
    t.float "iva_amount"
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["invoice_id"], name: "index_invoice_details_on_invoice_id"
    t.index ["product_id"], name: "index_invoice_details_on_product_id"
  end

  create_table "invoices", force: :cascade do |t|
    t.boolean "active"
    t.bigint "client_id"
    t.string "state", default: "Pendiente", null: false
    t.float "total", default: 0.0, null: false
    t.float "total_pay", default: 0.0, null: false
    t.string "header_result"
    t.string "authorized_on"
    t.string "cae_due_date"
    t.string "cae"
    t.string "cbte_tipo"
    t.bigint "sale_point_id"
    t.string "concepto"
    t.string "cbte_fch"
    t.float "imp_tot_conc", default: 0.0, null: false
    t.float "imp_op_ex", default: 0.0, null: false
    t.float "imp_trib", default: 0.0, null: false
    t.float "imp_neto", default: 0.0, null: false
    t.float "imp_iva", default: 0.0, null: false
    t.float "imp_total", default: 0.0, null: false
    t.integer "cbte_hasta"
    t.integer "cbte_desde"
    t.string "iva_cond"
    t.string "comp_number"
    t.bigint "company_id"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["client_id"], name: "index_invoices_on_client_id"
    t.index ["company_id"], name: "index_invoices_on_company_id"
    t.index ["sale_point_id"], name: "index_invoices_on_sale_point_id"
    t.index ["user_id"], name: "index_invoices_on_user_id"
  end

  create_table "iva_books", force: :cascade do |t|
    t.string "tipo"
    t.date "date"
    t.bigint "invoice_id"
    t.bigint "company_id"
    t.bigint "purchase_invoice_id"
    t.float "net_amount"
    t.float "iva_amount"
    t.float "total"
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_iva_books_on_company_id"
    t.index ["invoice_id"], name: "index_iva_books_on_invoice_id"
    t.index ["purchase_invoice_id"], name: "index_iva_books_on_purchase_invoice_id"
  end

  create_table "localities", force: :cascade do |t|
    t.string "name"
    t.integer "code"
    t.bigint "province_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["province_id"], name: "index_localities_on_province_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.string "title", null: false
    t.text "body", null: false
    t.string "link"
    t.time "read_at"
    t.bigint "sender_id", null: false
    t.bigint "receiver_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "payments", force: :cascade do |t|
    t.string "type_of_payment"
    t.float "total", default: 0.0, null: false
    t.boolean "active", default: true, null: false
    t.bigint "invoice_id"
    t.bigint "delayed_job_id"
    t.date "payment_date", default: -> { "CURRENT_DATE" }, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["invoice_id"], name: "index_payments_on_invoice_id"
  end

  create_table "permissions", force: :cascade do |t|
    t.string "action_name"
    t.text "description"
    t.bigint "friendly_name_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["friendly_name_id"], name: "index_permissions_on_friendly_name_id"
  end

  create_table "product_categories", force: :cascade do |t|
    t.string "name"
    t.integer "iva_aliquot"
    t.boolean "active"
    t.bigint "company_id"
    t.integer "products_count"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_product_categories_on_company_id"
  end

  create_table "product_price_histories", force: :cascade do |t|
    t.bigint "product_id"
    t.float "price"
    t.float "percentage"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id"], name: "index_product_price_histories_on_product_id"
  end

  create_table "products", force: :cascade do |t|
    t.string "code"
    t.string "name"
    t.boolean "active"
    t.bigint "product_category_id"
    t.bigint "company_id"
    t.float "cost_price"
    t.float "gain_margin"
    t.float "net_price"
    t.float "price"
    t.string "iva_aliquot"
    t.string "photo"
    t.string "measurement_unit"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_products_on_company_id"
    t.index ["product_category_id"], name: "index_products_on_product_category_id"
  end

  create_table "provinces", force: :cascade do |t|
    t.string "name"
    t.integer "code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "purchase_invoices", force: :cascade do |t|
    t.bigint "company_id"
    t.bigint "user_id"
    t.bigint "arrival_note_id"
    t.string "number", null: false
    t.bigint "supplier_id"
    t.string "cbte_tipo"
    t.date "date"
    t.float "net_amount", default: 0.0, null: false
    t.float "iva_amount", default: 0.0, null: false
    t.float "imp_op_ex", default: 0.0, null: false
    t.float "total", default: 0.0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["arrival_note_id"], name: "index_purchase_invoices_on_arrival_note_id"
    t.index ["company_id"], name: "index_purchase_invoices_on_company_id"
    t.index ["supplier_id"], name: "index_purchase_invoices_on_supplier_id"
    t.index ["user_id"], name: "index_purchase_invoices_on_user_id"
  end

  create_table "purchase_order_details", force: :cascade do |t|
    t.bigint "purchase_order_id"
    t.bigint "product_id"
    t.float "price", default: 0.0, null: false
    t.float "quantity", default: 1.0, null: false
    t.float "total", default: 0.0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id"], name: "index_purchase_order_details_on_product_id"
    t.index ["purchase_order_id"], name: "index_purchase_order_details_on_purchase_order_id"
  end

  create_table "purchase_orders", force: :cascade do |t|
    t.string "number", null: false
    t.string "state", default: "Pendiente de aprobación", null: false
    t.bigint "supplier_id"
    t.text "observation"
    t.float "total", default: 0.0, null: false
    t.float "total_pay", default: 0.0, null: false
    t.bigint "user_id"
    t.boolean "shipping", default: false, null: false
    t.float "shipping_cost", default: 0.0, null: false
    t.bigint "company_id"
    t.bigint "budget_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["budget_id"], name: "index_purchase_orders_on_budget_id"
    t.index ["company_id"], name: "index_purchase_orders_on_company_id"
    t.index ["supplier_id"], name: "index_purchase_orders_on_supplier_id"
    t.index ["user_id"], name: "index_purchase_orders_on_user_id"
  end

  create_table "receipts", force: :cascade do |t|
    t.bigint "invoice_id"
    t.boolean "active", default: true, null: false
    t.float "total", default: 0.0, null: false
    t.date "date", null: false
    t.string "observation"
    t.string "cbte_tipo", default: "01", null: false
    t.bigint "company_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_receipts_on_company_id"
    t.index ["invoice_id"], name: "index_receipts_on_invoice_id"
  end

  create_table "role_permissions", force: :cascade do |t|
    t.bigint "role_id"
    t.bigint "permission_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["permission_id"], name: "index_role_permissions_on_permission_id"
    t.index ["role_id"], name: "index_role_permissions_on_role_id"
  end

  create_table "roles", force: :cascade do |t|
    t.bigint "company_id"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_roles_on_company_id"
  end

  create_table "sale_points", force: :cascade do |t|
    t.bigint "company_id"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_sale_points_on_company_id"
  end

  create_table "stocks", force: :cascade do |t|
    t.bigint "product_id"
    t.bigint "depot_id"
    t.string "state"
    t.float "quantity"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["depot_id"], name: "index_stocks_on_depot_id"
    t.index ["product_id"], name: "index_stocks_on_product_id"
  end

  create_table "suppliers", force: :cascade do |t|
    t.string "name", null: false
    t.string "document_type"
    t.string "document_number"
    t.string "phone"
    t.string "mobile_phone"
    t.string "address"
    t.string "email"
    t.string "cbu"
    t.boolean "active", default: true, null: false
    t.bigint "company_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_suppliers_on_company_id"
  end

  create_table "user_activities", force: :cascade do |t|
    t.bigint "user_id"
    t.string "photo", null: false
    t.string "title", null: false
    t.text "body", null: false
    t.string "link"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_user_activities_on_user_id"
  end

  create_table "user_roles", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "role_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["role_id"], name: "index_user_roles_on_role_id"
    t.index ["user_id"], name: "index_user_roles_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.integer "company_id"
    t.string "first_name"
    t.string "last_name"
    t.integer "dni"
    t.date "birthday"
    t.string "address"
    t.boolean "active", default: true
    t.string "avatar"
    t.string "phone"
    t.string "mobile_phone"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.boolean "approved", default: false, null: false
    t.string "provider"
    t.string "uid"
    t.integer "postal_code"
    t.boolean "admin", default: true, null: false
    t.string "authentication_token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "province_id"
    t.bigint "locality_id"
    t.index ["company_id"], name: "index_users_on_company_id", unique: true
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["locality_id"], name: "index_users_on_locality_id"
    t.index ["province_id"], name: "index_users_on_province_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
  end

  add_foreign_key "account_movements", "clients"
  add_foreign_key "account_movements", "invoices"
  add_foreign_key "account_movements", "receipts"
  add_foreign_key "arrival_note_details", "arrival_notes"
  add_foreign_key "arrival_note_details", "products"
  add_foreign_key "arrival_notes", "companies"
  add_foreign_key "arrival_notes", "depots"
  add_foreign_key "arrival_notes", "purchase_orders"
  add_foreign_key "arrival_notes", "users"
  add_foreign_key "clients", "companies"
  add_foreign_key "clients", "users"
  add_foreign_key "delayed_jobs", "payments"
  add_foreign_key "delivery_notes", "clients"
  add_foreign_key "delivery_notes", "companies"
  add_foreign_key "delivery_notes", "invoices"
  add_foreign_key "delivery_notes", "users"
  add_foreign_key "depots", "companies"
  add_foreign_key "invoice_details", "invoices"
  add_foreign_key "invoice_details", "products"
  add_foreign_key "invoices", "clients"
  add_foreign_key "invoices", "companies"
  add_foreign_key "invoices", "sale_points"
  add_foreign_key "invoices", "users"
  add_foreign_key "iva_books", "companies"
  add_foreign_key "iva_books", "invoices"
  add_foreign_key "iva_books", "purchase_invoices"
  add_foreign_key "localities", "provinces"
  add_foreign_key "payments", "invoices"
  add_foreign_key "permissions", "friendly_names"
  add_foreign_key "product_categories", "companies"
  add_foreign_key "product_price_histories", "products"
  add_foreign_key "products", "companies"
  add_foreign_key "products", "product_categories"
  add_foreign_key "purchase_invoices", "arrival_notes"
  add_foreign_key "purchase_invoices", "companies"
  add_foreign_key "purchase_invoices", "suppliers"
  add_foreign_key "purchase_invoices", "users"
  add_foreign_key "purchase_order_details", "products"
  add_foreign_key "purchase_order_details", "purchase_orders"
  add_foreign_key "purchase_orders", "companies"
  add_foreign_key "purchase_orders", "suppliers"
  add_foreign_key "purchase_orders", "users"
  add_foreign_key "receipts", "companies"
  add_foreign_key "receipts", "invoices"
  add_foreign_key "role_permissions", "permissions"
  add_foreign_key "role_permissions", "roles"
  add_foreign_key "roles", "companies"
  add_foreign_key "sale_points", "companies"
  add_foreign_key "stocks", "depots"
  add_foreign_key "stocks", "products"
  add_foreign_key "suppliers", "companies"
  add_foreign_key "user_activities", "users"
  add_foreign_key "user_roles", "roles"
  add_foreign_key "user_roles", "users"
end
