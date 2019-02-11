class AccountMovement < ApplicationRecord
  belongs_to :client
  belongs_to :invoice, optional: true
  belongs_to :receipt, optional: true

  has_many :account_movement_payments, dependent: :destroy
  has_many :invoices, through: :account_movement_payments
  has_many :invoice_details, through: :invoices

  before_save :set_saldo_to_movements
  before_destroy :fix_saldo
  after_save  :update_debt
  after_destroy :update_debt
  after_destroy :destroy_receipt
  before_validation :check_receipt_attributes

  validate :check_pertenence_of_receipt_to_client

  default_scope { where(active: true ) }

  validates_presence_of :client_id, message: "El movimiento debe estar asociado a un cliente."
  validates_presence_of :cbte_tipo, message: "Debe definir el tipo de comprobante."
  validates_presence_of :total, message: "Debe definir un total."
  validates_presence_of :saldo, message: "Falta definir el saldo actual del cliente."
  validate :check_debe_haber

  accepts_nested_attributes_for :receipt, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :account_movement_payments, allow_destroy: true, reject_if: :all_blank

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

  COMP_TIPO = [
    "Factura A",
    "Nota de Crédito A",
    "Nota de Débito A",
    "Factura B",
    "Nota de Crédito B",
    "Nota de Débito B",
    "Factura C",
    "Nota de Crédito C",
    "Nota de Débito C",
    "Recibo X"
  ]

  #FILTROS DE BUSQUEDA
    def self.search_by_cbte_tipo cbte_tipo
      if !cbte_tipo.blank?
        where(cbte_tipo: cbte_tipo)
      else
        all
      end
    end

    def self.search_by_date from, to
      if !from.blank? && !to.blank?
        where(created_at: from..to)
      else
        all
      end
    end
  #FILTROS DE BUSQUEDA

  #ATRIBUTOS

  #ATRIBUTOS

  #VALIDACIONES
    def check_pertenence_of_receipt_to_client
      unless self.receipt.nil?
        errors.add(:base, "Cliente incorrecto") unless self.client_id == self.receipt.client_id
      end
    end
  #VALIDACIONES

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

    def fix_saldo
      self.total = 0
      set_saldo_to_movements
    end

  	def set_saldo_to_movements
  		debe_dif 	= debe ? (total - total_was) : 0.0
  		haber_dif	= haber ? (total - total_was) : 0.0
      total_dif = debe_dif + haber_dif

      if debe
        self.saldo = self.client.saldo + debe_dif
      else
        self.saldo = self.client.saldo - haber_dif
      end

      if total_dif != 0 && persisted?
    		next_movements = AccountMovement.where("created_at >= ? AND client_id = ?", created_at, client_id)
    		next_movements.each do |am|
    			total_saldo = am.saldo - total_dif
    			am.update_column(:saldo, total_saldo)
    		end
    		client.update_debt
      end
  	end

  	def update_debt
  		self.client.update_debt
  	end

    def destroy
      update_column(:active, false)
      run_callbacks :destroy
      freeze
    end

    def self.reset
      Invoice.destroy_all
      AccountMovement.destroy_all
      Receipt.destroy_all
      Client.update_all(saldo: 0)
      DailyCashMovement.destroy_all
    end
  #FUNCIONES

  #ATRIBUTOS
    def comprobante
      if not invoice_id.nil?
        "#{cbte_tipo.split().map{|w| w.first unless w.first != w.first.upcase}.join()} - #{invoice.comp_number}" #Transforma Nota de Crédito A => NCA
      else
        "#{cbte_tipo.split().map{|w| w.first unless w.first != w.first.upcase}.join()} - #{receipt.number}"
      end
    end

    def user_id=(user_id)
      @user_id = user_id
    end

    def user_id
      @user_id
    end

    def company_id=(company_id)
      @company_id = company_id
    end

    def company_id
      @company_id
    end
  #ATRIBUTOS

  #PROCESOS
    def check_receipt_attributes
      self.receipt.client_id  = self.client_id
      self.receipt.user_id    = self.user_id
      self.receipt.company_id = self.company_id
      self.receipt.date       = Date.today
      self.total              = self.receipt.total
    end

    def destroy_receipt
      self.receipt.destroy unless receipt.nil?
    end

    def check_debe_haber
      errors.add(:debe, "No se define si el movimiento pertenece al Debe o al Haber.") unless debe != haber
    end

    def self.create_from_receipt receipt
      am             = AccountMovement.where(receipt_id: receipt.id).first_or_initialize
      am.client_id   = receipt.client_id
      am.receipt_id  = receipt.id
      am.cbte_tipo   = Receipt::CBTE_TIPO[receipt.cbte_tipo]
      am.debe        = receipt.cbte_tipo == "99"
      am.haber       = receipt.cbte_tipo != "99"
      am.total       = receipt.total.to_f
      am.save
    end

    def self.create_from_invoice invoice
      if invoice.state == "Confirmado"
          am              = AccountMovement.where(invoice_id: invoice.id).first_or_initialize
          am.client_id    = invoice.client_id
          am.invoice_id   = invoice.id
          am.cbte_tipo    = Afip::CBTE_TIPO[invoice.cbte_tipo]
          am.observation  = invoice.observation
          if invoice.is_credit_note?
            am.debe         = false
            am.haber        = true
            am.total        = invoice.total.to_f
          else
            am.debe         = true
            am.haber        = false
            am.total        = invoice.total.to_f
          end
          am.save unless !am.changed?
          return am
        end
    end
  #PROCESOS
end
