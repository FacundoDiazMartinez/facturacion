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

ActiveRecord::Schema.define(version: 2018_10_11_194116) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

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
    t.string "city"
    t.string "location"
    t.string "postal_code"
    t.date "activity_init_date"
    t.string "contact_number"
    t.string "environment", default: "testing", null: false
    t.string "cbu"
    t.boolean "paid", default: false, null: false
    t.string "suscription_type"
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
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "company_id"
    t.string "first_name"
    t.string "last_name"
    t.integer "dni"
    t.date "birthday"
    t.string "address"
    t.boolean "active", default: true
    t.string "photo", default: "/images/default.png"
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
    t.string "name"
    t.string "provider_photo"
    t.float "comission_base", default: 0.0, null: false
    t.float "comission_amoun", default: 0.0, null: false
    t.string "province"
    t.string "city"
    t.integer "postal_code"
    t.string "system", default: "market", null: false
    t.boolean "admin", default: true, null: false
    t.integer "role_id"
    t.string "authentication_token"
    t.boolean "paid", default: false, null: false
    t.boolean "tutorial", default: true, null: false
    t.index ["company_id"], name: "index_users_on_company_id", unique: true
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
  end

  add_foreign_key "sale_points", "companies"
end
