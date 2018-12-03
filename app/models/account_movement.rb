class AccountMovement < ApplicationRecord
  belongs_to :client
  belongs_to :invoice, optional: true
  belongs_to :receipt, optional: true

  before_save :update_others_movements, if: Proc.new{|am|  !am.new_record?}
  after_save  :update_debt

  default_scope { where(active: true) }

  validates_presence_of :client_id, message: "El movimiento debe estar asociado a un cliente."
  validates_presence_of :cbte_tipo, message: "Debe definir el tipo de comprobante."
  validates_presence_of :total, message: "Debe definir un total."
  validates_presence_of :saldo, message: "Falta definir el saldo actual del cliente."
  validate :check_debe_haber

  #TABLA
    # create_table "account_movements", force: :cascade do |t|
    #   t.bigint "client_id"
    #   t.bigint "invoice_id"
    #   t.bigint "receipt_id"
    #   t.integer "days"
    #   t.string "cbte_tipo", null: false
    #   t.boolean "debe"
    #   t.boolean "haber"
    #   t.boolean "active", default: true, null: false
    #   t.float "total", default: 0.0, null: false
    #   t.float "saldo", default: 0.0, null: false
    #   t.datetime "created_at", null: false
    #   t.datetime "updated_at", null: false
    #   t.index ["client_id"], name: "index_account_movements_on_client_id"
    #   t.index ["invoice_id"], name: "index_account_movements_on_invoice_id"
    #   t.index ["receipt_id"], name: "index_account_movements_on_receipt_id"
    # end
  #TABLA

  #FUNCIONES
  	def days
  		(Date.today - created_at.to_date).to_i / 1.days 
  	end

  	def self.sum_total_from_invoices_per_client client_id
  		Client.find(client_id).invoices.select("invoices.total").sum(:total)
  	end

  	def self.sum_total_from_receipts_per_client client_id
  		Client.find(client_id).receipts.select("receipts.total").sum(:total)
  	end

  	def update_others_movements
  		debe_dif 	= debe ? (total - total_was) : 0.0
  		haber_dif	= haber ? (total - total_was) : 0.0
  		total_dif = debe_dif + haber_dif
  		next_movements = AccountMovement.where("created_at >= ? AND client_id = ?", created_at, client_id)
  		next_movements.each do |am|
  			total_saldo = am.saldo + total_dif
  			am.update_column(:saldo, total_saldo)
  		end
  		client.update_column(:saldo, client.saldo + total_dif)
  	end

  	def update_debt
  		saldo = AccountMovement.where(client_id: client_id).last.saldo
  		client.update_column(:saldo, saldo)
  	end

    def destroy
      update_column(:active, false)
      run_callbacks :destroy
      freeze
    end
  #FUNCIONES

  #PROCESOS
    def check_debe_haber
      errors.add(:debe, "No se define si el mvimiento pertenece al Debe o al Haber.") unless debe != haber
    end
  #PROCESOS
end
