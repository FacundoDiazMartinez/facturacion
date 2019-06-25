class AccountMovement < ApplicationRecord
  ##confirmado actua como una bandera que indica que el movimiento se registró en la cuenta corriente del cliente
  include Deleteable
  belongs_to :client#,  touch: true ##### COMENTADO PARA QUE SÓLO ACTUALICE MOVIMIENTOS CONFIRMADOS
  belongs_to :invoice, optional: true
  belongs_to :receipt, optional: true, touch: true

  has_many :account_movement_payments, dependent: :destroy
  has_many :invoices, through: :account_movement_payments
  has_many :invoice_details, through: :invoices
  has_many :income_payments, dependent: :destroy

  before_validation   :set_attrs_to_receipt
  after_touch         :payments_updated!
  after_destroy       :destroy_receipt

  default_scope { where(active: true) }
  scope :saldo_disponible_para_pagar, -> { where("account_movements.amount_available > 0.0 AND account_movements.receipt_id IS NOT NULL") }
  scope :saldo_por_notas_de_credito, -> { joins(:invoice).where("(invoices.cbte_tipo::integer IN (#{Invoice::COD_NC.join(', ')})) AND (account_movements.amount_available > 0)") }

  validates_presence_of     :client_id, message: "El movimiento debe estar asociado a un cliente."
  validates_presence_of     :cbte_tipo, message: "Debe definir el tipo de comprobante."
  validates_presence_of     :total, message: "Debe definir un total."
  validates_numericality_of :amount_available, greater_than_or_equal_to: 0.0, message: "El monto disponible para asignar debe ser mayor o igual a 0."
  validates_numericality_of :total, greater_than_or_equal_to: 0.0, message: "El monto pagado debe ser mayor o igual a 0."
  validates_presence_of     :saldo, message: "Falta definir el saldo actual del cliente."
  validate                  :check_pertenence_of_receipt_to_client
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

  ##los movimientos confirmados no calculan nuevamente
  def confirmado?
    self.tiempo_de_confirmacion.nil? ? false : true
  end
  #ATRIBUTOS

  #VALIDACIONES
  ##validación debe y haber (deben tener valores distintos)
  def check_debe_haber
    errors.add(:debe, "No se define si el movimiento pertenece al Debe o al Haber.") unless debe != haber
  end
  ##before_validation
  ##no sirve para el recibo si éste no se guarda!!!
  def set_attrs_to_receipt
    if !receipt.nil? && !client.nil?
      self.receipt.company_id = self.client.company_id
      self.receipt.date       = Date.today
    elsif client.nil?
      self.client_id          = self.receipt.client_id
      self.cbte_tipo          = self.receipt.cbte_tipo
    end
  end

  def check_pertenence_of_receipt_to_client
    unless self.receipt.nil?
      errors.add(:base, "Cliente incorrecto") unless self.client_id == self.receipt.client_id
    end
  end
  #VALIDACIONES

  #FUNCIONES
    #touch provocado por account_movement_payments
    def payments_updated!
      set_total_and_amount_available
      save #para que corra callbacks
    end

    ##calcula el total a partir de los pagos registrados (por el usuario)
    ##calcula el saldo disponible a partir de la diferencia entre el total y los pagos registrados por el sistema (pagos de comprobantes)
    def set_total_and_amount_available
      if self.account_movement_payments.any? ##no todos los movimientos tienen pagos
        unless confirmado?
          self.total = self.account_movement_payments.user_payments.sum(:total) ##el total del movimiento no debe cambiar para un mov confirmado
        end
        self.amount_available = self.total - self.account_movement_payments.system_payments.sum(:total)
      end
    end

    ##confirma el movimiento de cuenta para que impacte en la cuenta corriente del cliente
    ##actualiza el total del movimiento, el saldo disponible y el saldo correspondiente
    def confirmar!
      unless confirmado?
        self.account_movement_payments.map{ |payment| payment.confirmar }
        set_total_and_amount_available ##redundante?
        set_saldo
        pp "DESPUES DE ESTABLECER TOTAL, MONTO DISPONIBLE Y SALDO"
        pp self
        self.active                  = true
        self.tiempo_de_confirmacion  = DateTime.now ##bloquea el movimiento para que el saldo y el total no vuelvan a ser calculado
        self.save
        self.client.touch ##para que actualice su saldo con este movimiento de cuenta corriente
      end
    end

    ##calcula el saldo del movimiento antes de ser bloqueado
    def set_saldo
      unless confirmado?
        if debe
          self.saldo = self.client.saldo + self.total# el saldo aumenta
        elsif haber
          self.saldo = self.client.saldo - self.total# el saldo disminuye
        end
      end
    end

    ##calcula disponible para asignar
    ##utilizado en index de account_movements para mostrar el monto disponible para asignar
    def self.sum_available_amount_to_asign(client_id)
      client  = Client.find(client_id)
      var     = client.account_movements.saldo_por_notas_de_credito ##movimientos de cuenta para notas de cred
      var    += client.account_movements.saldo_disponible_para_pagar ##saldo disponible y pertenecientes a un remito
      sum     = var.map{|am| am.amount_available}.reduce(:+) ##suma los montos disponibles para asignar
      return sum.nil? ? 0 : sum
    end

    ##calcula los días restantes para pagar el comprobante asociado
  	def days
      unless self.invoice.blank?
        if self.invoice.cbte_fch.blank?
    		  (Date.today - self.invoice.created_at.to_date).to_i
        else
          (self.invoice.cbte_fch.to_date - self.invoice.created_at.to_date).to_i
        end
      end
  	end

    ##suma de los totales de los comprobantes
  	def self.sum_total_from_invoices_per_client client_id
  		Client.find(client_id).invoices.select("invoices.total").sum(:total)
  	end

    ##suma de los totales de los recibos
  	def self.sum_total_from_receipts_per_client client_id
  		Client.find(client_id).receipts.select("receipts.total").sum(:total)
  	end

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
    ##no es utilizado
    def check_receipt_attributes
      self.receipt.client_id  = self.client_id
      self.receipt.user_id    = self.user_id
      self.receipt.company_id = self.company_id
      self.receipt.date       = Date.today
      self.total              = self.receipt.total
    end

    ##elimina el recibo
    ##los recibos confirmados no deben poder eliminarse
    def destroy_receipt
      self.receipt.destroy unless receipt.nil?
    end

    ##genera movimiento de cuenta corriente ROJO desde una factura (o nota) o VERDE desde una nota
    def self.create_from_invoice invoice, old_real_total_left
      if invoice.confirmado?
          am              = AccountMovement.where(invoice_id: invoice.id).first_or_initialize
          am.client_id    = invoice.client_id
          am.invoice_id   = invoice.id
          am.cbte_tipo    = Afip::CBTE_TIPO[invoice.cbte_tipo]
          am.observation  = invoice.observation
          am.total        = invoice.total.to_f
          if invoice.is_credit_note?
            #am.amount_available = invoice.total - old_real_total_left
            am.debe         = false
            am.haber        = true
          else
            am.debe         = true
            am.haber        = false
          end
          if am.save
            am.confirmar!
          else
            pp am.errors
          end
          return am
        end
    end

    def self.generate_from_receipt_from_invoice receipt, invoice
      account_movement = create_from_receipt receipt
      AccountMovement.unscoped do
        self.generate_account_movement_payment invoice, account_movement.id
      end
    end

    ##guarda y devuelte un movimiento de cuenta inactivo para un recibo
    def self.create_from_receipt receipt
      if receipt.persisted?
        am             = AccountMovement.unscoped.where(receipt_id: receipt.id).first_or_initialize
        am.client_id   = receipt.client_id
        am.receipt_id  = receipt.id
        am.cbte_tipo   = Receipt::CBTE_TIPO[receipt.cbte_tipo]
        am.debe        = receipt.cbte_tipo == "99"
        am.haber       = receipt.cbte_tipo != "99"
        am.total       = receipt.total.to_f
        am.saldo       = 0 #receipt.client.saldo - receipt.total.to_f ##el saldo es igual al saldo del cliente menos el total del remito
        am.active      = false ##el recibo debe ser el encargado de confirmar el movimiento de cuenta
        am.save
        return am
      end
    end

    ##utilizado para registrar pagos en un recibo generado a partir de una factura
    def self.generate_account_movement_payment invoice, account_movement_id
      invoice.income_payments.where(generated_by_system: false, account_movement_id: nil).each do |income_payment| ##itera sobre los pagos de la factura
        income_payment.account_movement_id = account_movement_id ##asocia los pagos de la factura con el movimiento de cuenta del recibo para evitar duplicación
        income_payment.invoice_id          = nil ##desvincula el pago de la factura
        income_payment.save
      end
    end

    ##sólo debe ser posible para movimientos de cuenta no gravados
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
