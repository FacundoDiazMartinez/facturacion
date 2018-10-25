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

ActiveRecord::Schema.define(version: 2018_10_19_181256) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

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
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_clients_on_company_id"
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

  create_table "invoice_details", force: :cascade do |t|
    t.bigint "invoice_id"
    t.bigint "product_id"
    t.float "quantity", default: 1.0, null: false
    t.string "measurement_unit", null: false
    t.float "price_per_unit", default: 0.0, null: false
    t.float "bonus_percentage", default: 0.0, null: false
    t.float "bonus_amount", default: 0.0, null: false
    t.float "subtotal", default: 0.0, null: false
    t.integer "iva_aliquot"
    t.float "iva_amount"
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

  create_table "localities", force: :cascade do |t|
    t.string "name"
    t.integer "code"
    t.bigint "province_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["province_id"], name: "index_localities_on_province_id"
  end

  create_table "payments", force: :cascade do |t|
    t.string "type_of_payment"
    t.float "total"
    t.bigint "invoice_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["invoice_id"], name: "index_payments_on_invoice_id"
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

  create_table "products", force: :cascade do |t|
    t.string "code"
    t.string "name"
    t.boolean "active"
    t.bigint "product_category_id"
    t.bigint "company_id"
    t.float "list_price"
    t.float "price"
    t.float "net_price"
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

  create_table "sale_points", force: :cascade do |t|
    t.bigint "company_id"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_sale_points_on_company_id"
  end

  create_table "stocks", force: :cascade do |t|
    t.bigint "product_id"
    t.string "state"
    t.float "quantity"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id"], name: "index_stocks_on_product_id"
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

  add_foreign_key "clients", "companies"
  add_foreign_key "invoice_details", "invoices"
  add_foreign_key "invoice_details", "products"
  add_foreign_key "invoices", "clients"
  add_foreign_key "invoices", "companies"
  add_foreign_key "invoices", "sale_points"
  add_foreign_key "invoices", "users"
  add_foreign_key "localities", "provinces"
  add_foreign_key "payments", "invoices"
  add_foreign_key "product_categories", "companies"
  add_foreign_key "products", "companies"
  add_foreign_key "products", "product_categories"
  add_foreign_key "sale_points", "companies"
  add_foreign_key "stocks", "products"
end
