# frozen_string_literal: true

class DeviseCreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      ## Database authenticatable
      t.string :email,              null: false, default: ""
      t.string :encrypted_password, null: false, default: ""

      ## Recoverable
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at

      ## Rememberable
      t.datetime :remember_created_at

      t.integer  "sign_in_count",          default: 0,                     null: false
      t.datetime "current_sign_in_at"
      t.datetime "last_sign_in_at"
      t.inet     "current_sign_in_ip"
      t.inet     "last_sign_in_ip"
      t.datetime "created_at",                                             null: false
      t.datetime "updated_at",                                             null: false
      t.integer  "company_id"
      t.string   "first_name"
      t.string   "last_name"
      t.integer  "dni"
      t.date     "birthday"
      t.string   "address"
      t.boolean  "active",                 default: true
      t.string   "photo",                  default: "/images/default.png"
      t.string   "phone"
      t.string   "mobile_phone"
      t.string   "confirmation_token"
      t.datetime "confirmed_at"
      t.datetime "confirmation_sent_at"
      t.string   "unconfirmed_email"
      t.integer  "failed_attempts",        default: 0,                     null: false
      t.string   "unlock_token"
      t.datetime "locked_at"
      t.boolean  "approved",               default: false,                 null: false
      t.string   "provider"
      t.string   "uid"
      t.string   "name"
      t.string   "provider_photo"
      t.float    "comission_base",         default: 0.0,                   null: false
      t.float    "comission_amoun",        default: 0.0,                   null: false
      t.string   "province"
      t.string   "city"
      t.integer  "postal_code"
      t.string   "system",                 default: "market",              null: false
      t.boolean  "admin",                  default: true,                  null: false
      t.integer  "role_id"
      t.string   "authentication_token"
      t.boolean  "paid",                   default: false,                 null: false
      t.boolean  "tutorial",               default: true,                  null: false

      ## Trackable
      # t.integer  :sign_in_count, default: 0, null: false
      # t.datetime :current_sign_in_at
      # t.datetime :last_sign_in_at
      # t.inet     :current_sign_in_ip
      # t.inet     :last_sign_in_ip

      ## Confirmable
      # t.string   :confirmation_token
      # t.datetime :confirmed_at
      # t.datetime :confirmation_sent_at
      # t.string   :unconfirmed_email # Only if using reconfirmable

      ## Lockable
      # t.integer  :failed_attempts, default: 0, null: false # Only if lock strategy is :failed_attempts
      # t.string   :unlock_token # Only if unlock strategy is :email or :both
      # t.datetime :locked_at


      t.timestamps null: false
    end

    add_index :users, :email,                unique: true
    add_index :users, :reset_password_token, unique: true
    add_index :users, :confirmation_token,   unique: true
    add_index :users, :unlock_token,         unique: true
    add_index :users, :company_id,           unique: true

  end
end