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

ActiveRecord::Schema.define(version: 2020_05_14_204554) do

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
    t.text "observation"
    t.float "amount_available", default: 0.0, null: false
    t.datetime "tiempo_de_confirmacion"
    t.index ["client_id"], name: "index_account_movements_on_client_id"
    t.index ["invoice_id"], name: "index_account_movements_on_invoice_id"
    t.index ["receipt_id"], name: "index_account_movements_on_receipt_id"
  end

  create_table "account_payments", force: :cascade do |t|
    t.float "total", default: 0.0, null: false
    t.boolean "active", default: true, null: false
    t.bigint "payment_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["payment_id"], name: "index_account_payments_on_payment_id"
  end

  create_table "advertisements", force: :cascade do |t|
    t.string "title", null: false
    t.text "body"
    t.string "image1"
    t.date "delivery_date"
    t.boolean "active", default: true, null: false
    t.string "state", default: "No enviado", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.bigint "company_id"
    t.index ["company_id"], name: "index_advertisements_on_company_id"
    t.index ["user_id"], name: "index_advertisements_on_user_id"
  end

  create_table "arrival_note_details", force: :cascade do |t|
    t.bigint "arrival_note_id"
    t.bigint "product_id"
    t.boolean "cumpliment"
    t.string "observation"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "req_quantity"
    t.boolean "completed", default: false, null: false
    t.float "quantity", default: 0.0, null: false
    t.index ["arrival_note_id"], name: "index_arrival_note_details_on_arrival_note_id"
    t.index ["product_id"], name: "index_arrival_note_details_on_product_id"
  end

  create_table "arrival_notes", force: :cascade do |t|
    t.bigint "company_id"
    t.bigint "purchase_order_id"
    t.bigint "user_id"
    t.bigint "depot_id"
    t.string "number", null: false
    t.boolean "active", default: true, null: false
    t.string "state", default: "Pendiente", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_arrival_notes_on_company_id"
    t.index ["depot_id"], name: "index_arrival_notes_on_depot_id"
    t.index ["purchase_order_id"], name: "index_arrival_notes_on_purchase_order_id"
    t.index ["user_id"], name: "index_arrival_notes_on_user_id"
  end

  create_table "authorized_personals", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "dni"
    t.boolean "need_purchase_order"
    t.bigint "client_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["client_id"], name: "index_authorized_personals_on_client_id"
  end

  create_table "bank_payments", force: :cascade do |t|
    t.bigint "bank_id"
    t.bigint "payment_id"
    t.float "total", default: 0.0, null: false
    t.string "ticket"
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["bank_id"], name: "index_bank_payments_on_bank_id"
    t.index ["payment_id"], name: "index_bank_payments_on_payment_id"
  end

  create_table "banks", force: :cascade do |t|
    t.string "name", null: false
    t.string "cbu", null: false
    t.string "account_number"
    t.bigint "company_id"
    t.float "current_amount", default: 0.0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_banks_on_company_id"
  end

  create_table "bonifications", force: :cascade do |t|
    t.float "subtotal", null: false
    t.string "observation"
    t.float "percentage", default: 0.0, null: false
    t.float "amount", default: 0.0, null: false
    t.bigint "invoice_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["invoice_id"], name: "index_bonifications_on_invoice_id"
  end

  create_table "budget_details", force: :cascade do |t|
    t.float "price_per_unit", default: 0.0, null: false
    t.string "product_name", null: false
    t.string "measurement_unit", null: false
    t.float "quantity", default: 1.0, null: false
    t.float "bonus_percentage", default: 0.0, null: false
    t.float "bonus_amount", default: 0.0, null: false
    t.float "subtotal", default: 0.0, null: false
    t.boolean "active", default: true, null: false
    t.bigint "product_id"
    t.bigint "depot_id"
    t.bigint "budget_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "iva_aliquot"
    t.float "iva_amount"
    t.index ["budget_id"], name: "index_budget_details_on_budget_id"
    t.index ["depot_id"], name: "index_budget_details_on_depot_id"
    t.index ["product_id"], name: "index_budget_details_on_product_id"
  end

  create_table "budgets", force: :cascade do |t|
    t.date "date", default: -> { "CURRENT_DATE" }, null: false
    t.string "state", null: false
    t.date "expiration_date"
    t.string "number"
    t.float "total", default: 0.0, null: false
    t.boolean "active", default: true, null: false
    t.bigint "company_id"
    t.bigint "user_id"
    t.bigint "client_id"
    t.boolean "reserv_stock", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "observation"
    t.text "internal_observation"
    t.index ["client_id"], name: "index_budgets_on_client_id"
    t.index ["company_id"], name: "index_budgets_on_company_id"
    t.index ["user_id"], name: "index_budgets_on_user_id"
  end

  create_table "card_payments", force: :cascade do |t|
    t.bigint "payment_id"
    t.bigint "credit_card_id"
    t.float "subtotal", default: 0.0, null: false
    t.integer "installments", default: 1, null: false
    t.float "interest_rate_percentage", default: 0.0, null: false
    t.float "interest_rate_amount", default: 0.0, null: false
    t.float "total", default: 0.0, null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "fee_id"
    t.decimal "fee_subtotal", precision: 8, scale: 2
    t.index ["credit_card_id"], name: "index_card_payments_on_credit_card_id"
    t.index ["fee_id"], name: "index_card_payments_on_fee_id"
    t.index ["payment_id"], name: "index_card_payments_on_payment_id"
  end

  create_table "cash_payments", force: :cascade do |t|
    t.float "total", default: 0.0, null: false
    t.bigint "payment_id"
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["payment_id"], name: "index_cash_payments_on_payment_id"
  end

  create_table "cheque_payments", force: :cascade do |t|
    t.string "state", default: "No cobrado", null: false
    t.date "expiration", default: -> { "CURRENT_DATE" }, null: false
    t.float "total", default: 0.0, null: false
    t.text "observation"
    t.boolean "active", default: true, null: false
    t.string "origin", default: "De tercero", null: false
    t.string "entity", null: false
    t.string "number", null: false
    t.bigint "payment_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "issuance_date", default: -> { "CURRENT_DATE" }, null: false
    t.index ["payment_id"], name: "index_cheque_payments_on_payment_id"
  end

  create_table "client_contacts", force: :cascade do |t|
    t.bigint "client_id"
    t.string "name"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "charge"
    t.string "phone"
    t.index ["client_id"], name: "index_client_contacts_on_client_id"
  end

  create_table "clients", force: :cascade do |t|
    t.string "name", null: false
    t.string "address"
    t.string "document_type", default: "D.N.I.", null: false
    t.string "document_number", null: false
    t.boolean "active", default: true, null: false
    t.string "iva_cond", default: "Responsable Monotributo", null: false
    t.bigint "company_id"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "saldo", precision: 8, scale: 2, default: "0.0", null: false
    t.float "recharge"
    t.string "payment_day"
    t.string "observation"
    t.boolean "valid_for_account", default: false, null: false
    t.string "contact_1"
    t.string "contact_2"
    t.boolean "enabled", default: true, null: false
    t.string "enabled_observation"
    t.index ["company_id"], name: "index_clients_on_company_id"
    t.index ["user_id"], name: "index_clients_on_user_id"
  end

  create_table "commissioners", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "invoice_detail_id"
    t.float "percentage", default: 0.0, null: false
    t.boolean "active", default: false, null: false
    t.float "total_commission", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["invoice_detail_id"], name: "index_commissioners_on_invoice_detail_id"
    t.index ["user_id"], name: "index_commissioners_on_user_id"
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
    t.string "invoice_footer"
    t.boolean "active", default: true, null: false
    t.index ["locality_id"], name: "index_companies_on_locality_id"
    t.index ["province_id"], name: "index_companies_on_province_id"
  end

  create_table "compensation_payments", force: :cascade do |t|
    t.float "total", null: false
    t.bigint "payment_id"
    t.boolean "active", default: true, null: false
    t.string "asociatedClientInvoice"
    t.text "observation"
    t.string "concept"
    t.bigint "client_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["client_id"], name: "index_compensation_payments_on_client_id"
    t.index ["payment_id"], name: "index_compensation_payments_on_payment_id"
  end

  create_table "credit_card_payments", force: :cascade do |t|
    t.bigint "payment_id"
    t.bigint "credit_card_id"
    t.float "amount", default: 0.0, null: false
    t.string "tipo", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["credit_card_id"], name: "index_credit_card_payments_on_credit_card_id"
    t.index ["payment_id"], name: "index_credit_card_payments_on_payment_id"
  end

  create_table "credit_cards", force: :cascade do |t|
    t.string "name", null: false
    t.bigint "company_id"
    t.float "current_amount", default: 0.0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "enabled", default: true, null: false
    t.string "type_of_fee", default: "Porcentaje", null: false
    t.string "fav_logo", default: "credit-card", null: false
    t.boolean "active", default: true, null: false
    t.index ["company_id"], name: "index_credit_cards_on_company_id"
  end

  create_table "daily_cash_movements", force: :cascade do |t|
    t.bigint "daily_cash_id"
    t.string "movement_type", default: "Ajuste", null: false
    t.float "amount", default: 0.0, null: false
    t.string "associated_document"
    t.string "payment_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "flow", default: "income", null: false
    t.bigint "payment_id"
    t.string "observation"
    t.bigint "user_id"
    t.float "current_balance", default: 0.0, null: false
    t.boolean "active", default: true, null: false
    t.bigint "updated_by"
    t.datetime "date"
    t.index ["daily_cash_id"], name: "index_daily_cash_movements_on_daily_cash_id"
    t.index ["payment_id"], name: "index_daily_cash_movements_on_payment_id"
    t.index ["user_id"], name: "index_daily_cash_movements_on_user_id"
  end

  create_table "daily_cashes", force: :cascade do |t|
    t.bigint "company_id"
    t.string "state"
    t.float "initial_amount", default: 0.0, null: false
    t.float "final_amount", default: 0.0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "date", null: false
    t.float "current_amount", null: false
    t.boolean "active", default: true, null: false
    t.index ["company_id"], name: "index_daily_cashes_on_company_id"
  end

  create_table "debit_payments", force: :cascade do |t|
    t.bigint "bank_id"
    t.bigint "payment_id"
    t.float "total", null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["bank_id"], name: "index_debit_payments_on_bank_id"
    t.index ["payment_id"], name: "index_debit_payments_on_payment_id"
  end

  create_table "default_tributes", force: :cascade do |t|
    t.bigint "company_id"
    t.integer "tribute_id", null: false
    t.float "default_aliquot", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_default_tributes_on_company_id"
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

  create_table "delivery_note_details", force: :cascade do |t|
    t.bigint "delivery_note_id"
    t.bigint "product_id"
    t.bigint "depot_id"
    t.float "quantity", null: false
    t.string "observation"
    t.boolean "active", default: true, null: false
    t.boolean "cumpliment", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "invoice_detail_id"
    t.index ["delivery_note_id"], name: "index_delivery_note_details_on_delivery_note_id"
    t.index ["depot_id"], name: "index_delivery_note_details_on_depot_id"
    t.index ["invoice_detail_id"], name: "index_delivery_note_details_on_invoice_detail_id"
    t.index ["product_id"], name: "index_delivery_note_details_on_product_id"
  end

  create_table "delivery_notes", force: :cascade do |t|
    t.bigint "company_id"
    t.bigint "invoice_id"
    t.bigint "user_id"
    t.bigint "client_id"
    t.string "number", null: false
    t.boolean "active", default: true, null: false
    t.string "state", default: "Pendiente", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "date", default: -> { "CURRENT_DATE" }, null: false
    t.string "generated_by", default: "system", null: false
    t.text "observation"
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

  create_table "fees", force: :cascade do |t|
    t.bigint "credit_card_id"
    t.integer "quantity", null: false
    t.float "coefficient", default: 0.0, null: false
    t.float "tna"
    t.float "tem"
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "percentage", default: 0.0
    t.index ["credit_card_id"], name: "index_fees_on_credit_card_id"
  end

  create_table "friendly_names", force: :cascade do |t|
    t.string "name"
    t.string "subject_class"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "active", default: true, null: false
  end

  create_table "invoice_details", force: :cascade do |t|
    t.bigint "invoice_id"
    t.bigint "product_id"
    t.float "quantity", default: 0.0, null: false
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
    t.bigint "user_id"
    t.bigint "depot_id"
    t.bigint "associated_detail"
    t.index ["depot_id"], name: "index_invoice_details_on_depot_id"
    t.index ["invoice_id"], name: "index_invoice_details_on_invoice_id"
    t.index ["product_id"], name: "index_invoice_details_on_product_id"
    t.index ["user_id"], name: "index_invoice_details_on_user_id"
  end

  create_table "invoices", force: :cascade do |t|
    t.boolean "active", default: true, null: false
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
    t.bigint "associated_invoice"
    t.date "fch_serv_desde"
    t.date "fch_serv_hasta"
    t.date "fch_vto_pago"
    t.text "observation"
    t.bigint "budget_id"
    t.boolean "expired", default: false
    t.float "bonification", default: 0.0, null: false
    t.decimal "base_imponible", precision: 8, scale: 2, default: "0.0"
    t.decimal "total_tributos", precision: 8, scale: 2, default: "0.0"
    t.boolean "on_account", default: false, null: false
    t.boolean "delivered", default: false, null: false
    t.index ["budget_id"], name: "index_invoices_on_budget_id"
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
    t.boolean "active", default: true, null: false
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
    t.text "description"
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
    t.string "flow", default: "income", null: false
    t.bigint "purchase_order_id"
    t.bigint "account_movement_id"
    t.boolean "generated_by_system", default: false, null: false
    t.bigint "company_id"
    t.bigint "user_id"
    t.bigint "client_id"
    t.boolean "confirmed", default: false, null: false
    t.index ["account_movement_id"], name: "index_payments_on_account_movement_id"
    t.index ["client_id"], name: "index_payments_on_client_id"
    t.index ["company_id"], name: "index_payments_on_company_id"
    t.index ["invoice_id"], name: "index_payments_on_invoice_id"
    t.index ["purchase_order_id"], name: "index_payments_on_purchase_order_id"
    t.index ["user_id"], name: "index_payments_on_user_id"
  end

  create_table "permissions", force: :cascade do |t|
    t.string "action_name"
    t.text "description"
    t.bigint "friendly_name_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "active", default: true, null: false
    t.index ["friendly_name_id"], name: "index_permissions_on_friendly_name_id"
  end

  create_table "price_changes", force: :cascade do |t|
    t.string "name", null: false
    t.bigint "company_id"
    t.bigint "supplier_id"
    t.bigint "product_category_id"
    t.bigint "creator_id"
    t.bigint "applicator_id"
    t.datetime "application_date"
    t.decimal "modification", null: false
    t.boolean "applied", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["applicator_id"], name: "index_price_changes_on_applicator_id"
    t.index ["company_id"], name: "index_price_changes_on_company_id"
    t.index ["creator_id"], name: "index_price_changes_on_creator_id"
    t.index ["product_category_id"], name: "index_price_changes_on_product_category_id"
    t.index ["supplier_id"], name: "index_price_changes_on_supplier_id"
  end

  create_table "product_categories", force: :cascade do |t|
    t.string "name"
    t.bigint "company_id"
    t.integer "products_count"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "supplier_id"
    t.boolean "active", default: true, null: false
    t.string "iva_aliquot", default: "05", null: false
    t.index ["company_id"], name: "index_product_categories_on_company_id"
    t.index ["supplier_id"], name: "index_product_categories_on_supplier_id"
  end

  create_table "product_price_histories", force: :cascade do |t|
    t.bigint "product_id"
    t.float "price"
    t.float "percentage"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "created_by"
    t.index ["product_id"], name: "index_product_price_histories_on_product_id"
  end

  create_table "products", force: :cascade do |t|
    t.string "code"
    t.string "name"
    t.boolean "active", default: true, null: false
    t.bigint "product_category_id"
    t.bigint "company_id"
    t.float "cost_price"
    t.float "gain_margin"
    t.float "net_price"
    t.float "price"
    t.string "iva_aliquot", default: "05", null: false
    t.string "photo"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "created_by"
    t.bigint "updated_by"
    t.string "measurement"
    t.string "tipo", default: "Producto", null: false
    t.bigint "supplier_id"
    t.float "minimum_stock"
    t.float "recommended_stock"
    t.float "available_stock", default: 0.0, null: false
    t.string "measurement_unit", default: "7", null: false
    t.string "supplier_code"
    t.bigint "product_id"
    t.boolean "notification_sended", default: false, null: false
    t.index ["company_id"], name: "index_products_on_company_id"
    t.index ["product_category_id"], name: "index_products_on_product_category_id"
    t.index ["product_id"], name: "index_products_on_product_id"
    t.index ["supplier_id"], name: "index_products_on_supplier_id"
  end

  create_table "provinces", force: :cascade do |t|
    t.string "name"
    t.integer "code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "active", default: true, null: false
  end

  create_table "purchase_invoices", force: :cascade do |t|
    t.bigint "company_id"
    t.bigint "user_id"
    t.bigint "arrival_note_id"
    t.string "number", null: false
    t.bigint "supplier_id"
    t.string "cbte_tipo"
    t.date "date"
    t.decimal "net_amount", precision: 10, scale: 2, default: "0.0", null: false
    t.decimal "iva_amount", precision: 10, scale: 2, default: "0.0", null: false
    t.decimal "imp_op_ex", precision: 10, scale: 2, default: "0.0", null: false
    t.decimal "total", precision: 10, scale: 2, default: "0.0", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "purchase_order_id"
    t.boolean "active", default: true
    t.string "cae"
    t.decimal "percep", precision: 10, scale: 2, default: "0.0", null: false
    t.index ["arrival_note_id"], name: "index_purchase_invoices_on_arrival_note_id"
    t.index ["company_id"], name: "index_purchase_invoices_on_company_id"
    t.index ["purchase_order_id"], name: "index_purchase_invoices_on_purchase_order_id"
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
    t.string "state", default: "Pendiente", null: false
    t.bigint "supplier_id"
    t.text "observation"
    t.float "total", default: 0.0, null: false
    t.bigint "user_id"
    t.boolean "shipping", default: false, null: false
    t.float "shipping_cost", default: 0.0, null: false
    t.bigint "company_id"
    t.bigint "budget_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "active", default: true
    t.boolean "delivered", default: false, null: false
    t.date "date"
    t.index ["budget_id"], name: "index_purchase_orders_on_budget_id"
    t.index ["company_id"], name: "index_purchase_orders_on_company_id"
    t.index ["supplier_id"], name: "index_purchase_orders_on_supplier_id"
    t.index ["user_id"], name: "index_purchase_orders_on_user_id"
  end

  create_table "receipt_details", force: :cascade do |t|
    t.bigint "receipt_id"
    t.bigint "invoice_id"
    t.float "total", default: 0.0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "total_payed_boolean", default: false
    t.index ["invoice_id"], name: "index_receipt_details_on_invoice_id"
    t.index ["receipt_id"], name: "index_receipt_details_on_receipt_id"
  end

  create_table "receipts", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.float "total", default: 0.0, null: false
    t.date "date", null: false
    t.string "concept"
    t.bigint "company_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "number"
    t.string "cbte_tipo", default: "00", null: false
    t.bigint "client_id"
    t.bigint "sale_point_id"
    t.bigint "user_id"
    t.string "state", default: "Pendiente"
    t.float "saved_amount_available"
    t.index ["client_id"], name: "index_receipts_on_client_id"
    t.index ["company_id"], name: "index_receipts_on_company_id"
    t.index ["sale_point_id"], name: "index_receipts_on_sale_point_id"
    t.index ["user_id"], name: "index_receipts_on_user_id"
  end

  create_table "retention_payments", force: :cascade do |t|
    t.bigint "payment_id"
    t.boolean "active", default: true, null: false
    t.float "total", default: 0.0, null: false
    t.string "number", null: false
    t.text "observation"
    t.string "tribute", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["payment_id"], name: "index_retention_payments_on_payment_id"
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
    t.boolean "active", default: true, null: false
    t.index ["company_id"], name: "index_roles_on_company_id"
  end

  create_table "sale_points", force: :cascade do |t|
    t.bigint "company_id"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "active", default: true, null: false
    t.index ["company_id"], name: "index_sale_points_on_company_id"
  end

  create_table "sended_advertisements", force: :cascade do |t|
    t.bigint "advertisement_id"
    t.text "clients_data", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["advertisement_id"], name: "index_sended_advertisements_on_advertisement_id"
  end

  create_table "stocks", force: :cascade do |t|
    t.bigint "product_id"
    t.bigint "depot_id"
    t.string "state", null: false
    t.float "quantity", default: 0.0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "active", default: true, null: false
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
    t.string "titular"
    t.string "account_number"
    t.string "bank_name"
    t.string "iva_cond", null: false
    t.bigint "created_by"
    t.bigint "updated_by"
    t.index ["company_id"], name: "index_suppliers_on_company_id"
  end

  create_table "transfer_request_details", force: :cascade do |t|
    t.bigint "transfer_request_id"
    t.bigint "product_id"
    t.float "quantity", null: false
    t.boolean "active", default: true, null: false
    t.text "observation"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "product_code"
    t.index ["product_id"], name: "index_transfer_request_details_on_product_id"
    t.index ["transfer_request_id"], name: "index_transfer_request_details_on_transfer_request_id"
  end

  create_table "transfer_requests", force: :cascade do |t|
    t.bigint "company_id"
    t.bigint "user_id"
    t.bigint "transporter_id", null: false
    t.string "number", null: false
    t.string "state", default: "Pendiente", null: false
    t.string "observation"
    t.date "date", default: -> { "CURRENT_DATE" }, null: false
    t.bigint "from_depot_id", null: false
    t.bigint "to_depot_id", null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "sended_by"
    t.bigint "received_by"
    t.datetime "sended_at"
    t.datetime "received_at"
    t.index ["company_id"], name: "index_transfer_requests_on_company_id"
    t.index ["user_id"], name: "index_transfer_requests_on_user_id"
  end

  create_table "tributes", force: :cascade do |t|
    t.bigint "invoice_id"
    t.string "afip_id", null: false
    t.string "desc", null: false
    t.float "base_imp", default: 0.0, null: false
    t.float "alic", default: 0.0, null: false
    t.float "importe", default: 0.0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["invoice_id"], name: "index_tributes_on_invoice_id"
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
    t.boolean "active", default: true, null: false
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
    t.bigint "company_id"
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
    t.string "authentication_token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "province_id"
    t.bigint "locality_id"
    t.boolean "admin", default: false, null: false
    t.index ["company_id"], name: "index_users_on_company_id"
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
  add_foreign_key "account_payments", "payments"
  add_foreign_key "advertisements", "companies"
  add_foreign_key "advertisements", "users"
  add_foreign_key "arrival_note_details", "arrival_notes"
  add_foreign_key "arrival_note_details", "products"
  add_foreign_key "arrival_notes", "companies"
  add_foreign_key "arrival_notes", "depots"
  add_foreign_key "arrival_notes", "purchase_orders"
  add_foreign_key "arrival_notes", "users"
  add_foreign_key "authorized_personals", "clients"
  add_foreign_key "bank_payments", "banks"
  add_foreign_key "bank_payments", "payments"
  add_foreign_key "banks", "companies"
  add_foreign_key "bonifications", "invoices"
  add_foreign_key "budget_details", "budgets"
  add_foreign_key "budget_details", "depots"
  add_foreign_key "budget_details", "products"
  add_foreign_key "budgets", "clients"
  add_foreign_key "budgets", "companies"
  add_foreign_key "budgets", "users"
  add_foreign_key "card_payments", "credit_cards"
  add_foreign_key "card_payments", "fees"
  add_foreign_key "card_payments", "payments"
  add_foreign_key "cash_payments", "payments"
  add_foreign_key "cheque_payments", "payments"
  add_foreign_key "client_contacts", "clients"
  add_foreign_key "clients", "companies"
  add_foreign_key "clients", "users"
  add_foreign_key "commissioners", "invoice_details"
  add_foreign_key "commissioners", "users"
  add_foreign_key "compensation_payments", "clients"
  add_foreign_key "credit_card_payments", "credit_cards"
  add_foreign_key "credit_card_payments", "payments"
  add_foreign_key "credit_cards", "companies"
  add_foreign_key "daily_cash_movements", "daily_cashes"
  add_foreign_key "daily_cash_movements", "payments"
  add_foreign_key "daily_cash_movements", "users"
  add_foreign_key "daily_cashes", "companies"
  add_foreign_key "debit_payments", "banks"
  add_foreign_key "debit_payments", "payments"
  add_foreign_key "default_tributes", "companies"
  add_foreign_key "delayed_jobs", "payments"
  add_foreign_key "delivery_note_details", "delivery_notes"
  add_foreign_key "delivery_note_details", "depots"
  add_foreign_key "delivery_note_details", "invoice_details"
  add_foreign_key "delivery_note_details", "products"
  add_foreign_key "delivery_notes", "clients"
  add_foreign_key "delivery_notes", "companies"
  add_foreign_key "delivery_notes", "invoices"
  add_foreign_key "delivery_notes", "users"
  add_foreign_key "depots", "companies"
  add_foreign_key "fees", "credit_cards"
  add_foreign_key "invoice_details", "depots"
  add_foreign_key "invoice_details", "invoices"
  add_foreign_key "invoice_details", "products"
  add_foreign_key "invoice_details", "users"
  add_foreign_key "invoices", "budgets"
  add_foreign_key "invoices", "clients"
  add_foreign_key "invoices", "companies"
  add_foreign_key "invoices", "sale_points"
  add_foreign_key "invoices", "users"
  add_foreign_key "iva_books", "companies"
  add_foreign_key "iva_books", "invoices"
  add_foreign_key "iva_books", "purchase_invoices"
  add_foreign_key "localities", "provinces"
  add_foreign_key "payments", "account_movements"
  add_foreign_key "payments", "clients"
  add_foreign_key "payments", "companies"
  add_foreign_key "payments", "invoices"
  add_foreign_key "payments", "purchase_orders"
  add_foreign_key "payments", "users"
  add_foreign_key "permissions", "friendly_names"
  add_foreign_key "price_changes", "companies"
  add_foreign_key "price_changes", "product_categories"
  add_foreign_key "price_changes", "suppliers"
  add_foreign_key "price_changes", "users", column: "applicator_id"
  add_foreign_key "price_changes", "users", column: "creator_id"
  add_foreign_key "product_categories", "companies"
  add_foreign_key "product_categories", "suppliers"
  add_foreign_key "product_price_histories", "products"
  add_foreign_key "products", "companies"
  add_foreign_key "products", "product_categories"
  add_foreign_key "products", "products"
  add_foreign_key "products", "suppliers"
  add_foreign_key "purchase_invoices", "arrival_notes"
  add_foreign_key "purchase_invoices", "companies"
  add_foreign_key "purchase_invoices", "purchase_orders"
  add_foreign_key "purchase_invoices", "suppliers"
  add_foreign_key "purchase_invoices", "users"
  add_foreign_key "purchase_order_details", "products"
  add_foreign_key "purchase_order_details", "purchase_orders"
  add_foreign_key "purchase_orders", "companies"
  add_foreign_key "purchase_orders", "suppliers"
  add_foreign_key "purchase_orders", "users"
  add_foreign_key "receipt_details", "invoices"
  add_foreign_key "receipt_details", "receipts"
  add_foreign_key "receipts", "clients"
  add_foreign_key "receipts", "companies"
  add_foreign_key "receipts", "sale_points"
  add_foreign_key "receipts", "users"
  add_foreign_key "retention_payments", "payments"
  add_foreign_key "role_permissions", "permissions"
  add_foreign_key "role_permissions", "roles"
  add_foreign_key "roles", "companies"
  add_foreign_key "sale_points", "companies"
  add_foreign_key "sended_advertisements", "advertisements"
  add_foreign_key "stocks", "depots"
  add_foreign_key "stocks", "products"
  add_foreign_key "suppliers", "companies"
  add_foreign_key "transfer_request_details", "products"
  add_foreign_key "transfer_request_details", "transfer_requests"
  add_foreign_key "transfer_requests", "companies"
  add_foreign_key "transfer_requests", "users"
  add_foreign_key "tributes", "invoices"
  add_foreign_key "user_activities", "users"
  add_foreign_key "user_roles", "roles"
  add_foreign_key "user_roles", "users"
  add_foreign_key "users", "companies"
  add_foreign_key "users", "localities"
  add_foreign_key "users", "provinces"
end
