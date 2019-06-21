class AccountMovement < ApplicationRecord
  include Deleteable
  belongs_to :client,  touch: true
  belongs_to :invoice, optional: true
  belongs_to :receipt, optional: true, touch: true

  has_many :account_movement_payments, dependent: :destroy
  has_many :invoices, through: :account_movement_payments
  has_many :invoice_details, through: :invoices
  has_many :income_payments, dependent: :destroy

  before_validation   :set_attrs_to_receipt
  #before_save         :set_saldo_to_movements, if: Proc.new{ |am| am.active == true && am.active_was == true } #Porque cuando se crea (en segunda instancia) se setea el saldo. Cuando se crea el AM primero se crea con active=false y al confirmar recibo pasa a active=true
  before_save         :check_amount_available
  before_save         :set_saldo
  before_destroy      :fix_saldo
  after_touch         :payments_updated
  # after_save          :update_debt, unless: Proc.new{ |p| p.receipt.try(:state) == "Pendiente" } Comentado para probar touch al cliente
  # after_destroy       :update_debt
  after_destroy       :destroy_receipt

  validate :check_pertenence_of_receipt_to_client

  default_scope { where(active: true) }

  validates_presence_of     :client_id, message: "El movimiento debe estar asociado a un cliente."
  validates_presence_of     :cbte_tipo, message: "Debe definir el tipo de comprobante."
  validates_presence_of     :total, message: "Debe definir un total."
  #validates_numericality_of :amount_available, greater_than_or_equal_to: 0.0, message: "El monto a asignar debe ser mayor o igual a 0."
  validates_numericality_of :total, greater_than_or_equal_to: 0.0, message: "El monto pagado debe ser mayor o igual a 0."
  validates_presence_of     :saldo, message: "Falta definir el saldo actual del cliente."
  validate                  :check_debe_haber

  accepts_nested_attributes_for :receipt, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :account_movement_payments, allow_destroy: true, reject_if: Proc.new{|p| p["type_of_payment"].blank?}

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

  #ATRIBUTOS
  def saldo
    read_attribute("saldo").round(2)
  end

  def client
    Client.unscoped{ super }
  end

  def invoice
    Invoice.unscoped { super }
  end

  def comprobante
    if not invoice_id.nil?
      "#{cbte_tipo.split().map{|w| w.first unless w.first != w.first.upcase}.join()} - #{invoice.sale_point.name} - #{invoice.comp_number}" #Transforma Nota de Crédito A => NCA
    elsif cbte_tipo == "Devolución"
      "#{cbte_tipo.split().map{|w| w.first unless w.first != w.first.upcase}.join()} - #{receipt.sale_point.name} - #{receipt.number}"
    else #Recibo X
      "#{cbte_tipo[-1,1]} - #{receipt.sale_point.name} - #{receipt.number}"
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

  #VALIDACIONES
    def check_pertenence_of_receipt_to_client
      unless self.receipt.nil?
        errors.add(:base, "Cliente incorrecto") unless self.client_id == self.receipt.client_id
      end
    end

    def check_amount_available
		  if amount_available < 0
				amount_available = 0
			end
		end
  #VALIDACIONES

  #FUNCIONES
    #el touch lo provoca account movement payments
    def payments_updated
      pp "PAYMENTS UPDATED"
      #set_total_if_subpayments se comenta para probar set_saldo
      self.save #para que corra callbacks
      pp "FIN"
    end

    def set_saldo
      if self.active && (self.active_changed?) ## sólo funciona al confirmar el movimiento de cuenta
        if debe
          if self.invoice
            ##define el total nuevamente
            self.total            = self.invoice.total
            self.amount_available = 0
          end
          self.saldo = self.client.saldo + self.total
        elsif haber
          if self.account_movement_payments
            self.total            = self.account_movement_payments.where(generated_by_system: false).sum(:total) #pagos registrados por el usuario
            self.amount_available = self.total - self.account_movement_payments.where(generated_by_system: true).sum(:total) #pagos registrados por sistema
          end
          self.saldo = self.client.saldo - self.total
        end
      end
    end

    ## establece el total del movimiento de cuenta
    def set_total_if_subpayments
      if self.haber #sólo actualiza los movimientos de cuenta correspondiente a pagos
        if self.account_movement_payments
          self.total            = self.account_movement_payments.where(generated_by_system: false).sum(:total) #pagos registrados por el usuario
          self.amount_available = self.total - self.account_movement_payments.where(generated_by_system: true).sum(:total) #pagos registrados por sistema
        end
        self.saldo            = self.client.saldo - self.total
      end
      pp "SALDO #{self.saldo}"
    end

    def self.sum_available_amount_to_asign(client_id)
      client  = Client.find(client_id)
      var     = client.account_movements.joins(:invoice).where("(invoices.cbte_tipo::integer IN (#{Invoice::COD_NC.join(', ')})) AND (account_movements.amount_available > 0)")
      var    += client.account_movements.joins(:receipt).where("account_movements.amount_available > 0")
      sum     = var.map{|am| am.amount_available}.reduce(:+)
      return sum.nil? ? 0 : sum
    end

  	def days
      unless self.invoice.blank?
        if self.invoice.cbte_fch.blank?
    		  (Date.today - self.invoice.created_at.to_date).to_i
        else
          (self.invoice.cbte_fch.to_date - self.invoice.created_at.to_date).to_i
        end
      end
  	end

  	def self.sum_total_from_invoices_per_client client_id
  		Client.find(client_id).invoices.select("invoices.total").sum(:total)
  	end

  	def self.sum_total_from_receipts_per_client client_id
  		Client.find(client_id).receipts.select("receipts.total").sum(:total)
  	end

    def fix_saldo
      self.total = 0
      #set_saldo_to_movements
    end

    ## no sé que hace este codigo, pura confianza
  	# def set_saldo_to_movements
  	# 	debe_dif 	= self.debe  ? (self.total - self.total_was) : 0.0
  	# 	haber_dif	= self.haber ? (self.total - self.total_was) : 0.0
    #   total_dif = debe_dif + haber_dif
    #   pp "TOTAL DIF #{total_dif}"
    #   if debe
    #     self.saldo = self.client.saldo + debe_dif
    #   else
    #     self.saldo = self.client.saldo - haber_dif # 12000
    #   end
    #   if total_dif != 0 && persisted?
    # 		next_movements = AccountMovement.where("created_at >= ? AND client_id = ?", created_at, client_id)
    # 		next_movements.each do |am|
    # 			total_saldo = am.saldo - total_dif
    # 			am.update_column(:saldo, total_saldo)
    # 		end
    #   end
  	# end

    def self.del
      ReceiptDetail.delete_all
      IvaBook.delete_all
      InvoiceDetail.delete_all
      DailyCashMovement.delete_all
      Payment.delete_all
      AccountMovement.unscoped.delete_all
      Invoice.delete_all
      Receipt.delete_all
      Client.update_all(saldo: 0)
      DailyCashMovement.delete_all
    end

    def self.reset
      ReceiptDetail.unscoped.all.map{|am| am.destroy(:hard)}
      AccountMovement.unscoped.all.map{|am| am.destroy(:hard)}
      InvoiceDetail.unscoped.all.map{|am| am.destroy(:hard)}
      IvaBook.unscoped.all.map{|am| am.destroy(:hard)}
      Payment.unscoped.all.map{|am| am.destroy(:hard)}
      Invoice.unscoped.all.map{|am| am.destroy(:hard)}
      Receipt.unscoped.all.map{|am| am.destroy(:hard)}
      Client.update_all(saldo: 0)
      DailyCashMovement.unscoped.all.map{|am| am.destroy(:hard)}
    end
  #FUNCIONES

  #PROCESOS
    def set_attrs_to_receipt
      if !receipt.nil? && !client.nil?
        self.receipt.company_id = self.client.company_id
        self.receipt.date       = Date.today
      elsif client.nil?
        self.client_id          = self.receipt.client_id
        self.cbte_tipo          = self.receipt.cbte_tipo
      end
    end

    def set_amount_available
      self.update_columns(amount_available: self.account_movement_payments.where(generated_by_system: true).sum(:total))
    end

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

    ##confirma el movimiento de cuenta para que impacte en la cuenta corriente del cliente
    ##confirma los pagos pertenecientes a este movimiento de cuenta
    ##actualiza el total del movimiento y el saldo correspondiente
    def confirmar!
      self.account_movement_payments.map{ |payment| payment.confirmar! }
      #set_total_if_subpayments ## calcula total, saldo y monto disponible
      self.active = true
      self.save
    end

    def self.create_from_receipt receipt
      if receipt.persisted?
        am             = AccountMovement.unscoped.where(receipt_id: receipt.id).first_or_initialize
        am.client_id   = receipt.client_id
        am.receipt_id  = receipt.id
        am.cbte_tipo   = Receipt::CBTE_TIPO[receipt.cbte_tipo]
        am.debe        = receipt.cbte_tipo == "99"
        am.haber       = receipt.cbte_tipo != "99"
        am.total       = 0 #receipt.total.to_f
        am.saldo       = 0 #receipt.client.saldo - receipt.total.to_f ##el saldo es igual al saldo del cliente menos el total del remito
        am.active      = false ##el recibo debe ser el encargado de confirmar el movimiento de cuenta
        am.save
        return am
      end
    end

    # def update_debt
  	# 	self.client.update_debt
  	# end
    # comentado para probar touch al cliente

    #genera movimientos de cuenta corriente desde una factura (o nota)
    def self.create_from_invoice invoice, old_real_total_left
      if invoice.state == "Confirmado"
          am              = AccountMovement.where(invoice_id: invoice.id).first_or_initialize
          am.client_id    = invoice.client_id
          am.invoice_id   = invoice.id
          am.cbte_tipo    = Afip::CBTE_TIPO[invoice.cbte_tipo]
          am.observation  = invoice.observation
          am.total        = invoice.total.to_f
          if invoice.is_credit_note?
            am.amount_available = invoice.total - old_real_total_left
            am.debe         = false
            am.haber        = true
          else
            am.debe         = true
            am.haber        = false
          end
          ## no calcula saldo
          am.save if am.changed?
          pp am.errors
          return am
        end
    end

    def destroy
      update_column(:active, false)
      run_callbacks :destroy
    end
  #PROCESOS

  private
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
end
