class Invoice < ApplicationRecord
	belongs_to :client
	belongs_to :sale_point
	belongs_to :company
	belongs_to :user
  belongs_to :invoice, foreign_key: :associated_invoice, optional: true
  belongs_to :budget, optional: true

  has_many :notes, 															foreign_key: :associated_invoice, class_name: 'Invoice'
  has_many :debit_notes, 	-> { debit_notes }, 	foreign_key: :associated_invoice, class_name: 'Invoice'
  has_many :credit_notes, -> { credit_notes }, 	foreign_key: :associated_invoice, class_name: 'Invoice'
  has_many :income_payments, dependent: :destroy
  has_many :invoice_details, dependent: :destroy
  has_many :products, through: :invoice_details
  has_many :iva_books, dependent: :destroy
  has_many :delivery_notes, dependent: :destroy
  has_many :commissioners, through: :invoice_details
  has_many :tributes, dependent: :destroy
  has_many :receipt_details
  has_many :receipts, through: :receipt_details
  has_many :bonifications, dependent: :destroy
  has_one  :account_movement, dependent: :destroy

  accepts_nested_attributes_for :income_payments, allow_destroy: true, reject_if: Proc.new { |ip| ip["type_of_payment"].blank? }
  accepts_nested_attributes_for :invoice_details, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :tributes, 				allow_destroy: true, reject_if: Proc.new { |t| t["afip_id"].blank? }
	accepts_nested_attributes_for :bonifications, 	allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :client, 															 reject_if: :all_blank

	STATES = ["Pendiente", "Confirmado", "Anulado", "Anulado parcialmente"]
  COD_INVOICE = ["01", "06", "11"]
  COD_ND = ["02", "07", "12"]
  COD_NC = ["03", "08", "13"]

	before_validation         :stock_between_invoice_and_credit_notes
	validates_presence_of 		:client_id, message: "El comprobante debe estar asociado a un cliente."
	validates	 								:total, presence: { message: "El total no debe estar en blanco." },
																		numericality: { greater_than_or_equal_to: 0.0, message: "El total debe ser mayor o igual a 0." }
	validates_presence_of 		:total_pay, message: "El total pagado no debe estar en blanco."
	validates_presence_of 		:sale_point_id, message: "El punto de venta no debe estar en blanco."
	validates_presence_of			:invoice_details, message: "El comprobante debe tener al menos 1 (un) concepto."
	validates_inclusion_of 		:state, in: STATES, message: "Estado inválido."
	validates_uniqueness_of 	:associated_invoice, scope: [:company_id, :active, :cbte_tipo, :state], allow_blank: true, if: Proc.new{ |i| i.state == "Pendiente" }
	validate 									:verifica_confirmado, :cliente_habilitado, :tipo_de_comprobante_habilitado, :fecha_de_servicio

	after_save 		:touch_commissioners, :touch_payments, :impact_stock_if_cn, :check_cancelled_state_of_invoice
  after_save 		:set_invoice_activity, if: Proc.new{ |i| (i.state == "Confirmado" || i.state == "Anulado") && (i.changed?) }
	after_touch 	:update_total_pay

	default_scope { where(active: true) }
	scope :confirmados, 						-> { where(state: ["Confirmado", "Anulado parcialmente"]) }
	scope :only_invoices, 					-> { where(cbte_tipo: COD_INVOICE) }
	scope :facturas_y_notas_debito, -> { where(cbte_tipo: COD_INVOICE + COD_ND) }
	scope :unassociated_invoices, 	-> { where(associated_invoice: nil) }
	scope :debit_notes, 						-> { where(cbte_tipo: COD_ND).where(state: "Confirmado") }
	scope :credit_notes, 						-> { where(cbte_tipo: COD_NC).where(state: "Confirmado") }
	scope :pendientes_de_entrega,		-> { where(delivered: false) }

	def self.search_by_client name
		return all if name.blank?
		joins(:client).where("clients.name ILIKE ?", "%#{name}%")
	end

	def self.search_by_tipo tipo
		return all if tipo.blank?
		where(cbte_tipo: tipo)
	end

	def self.search_by_state state
		return all if state.blank?
		where(state: state)
	end

  def self.search_by_number comp_number
    return all if comp_number.blank?
    where("comp_number ILIKE ?", "%#{comp_number}%")
  end

	def verifica_confirmado
		errors.add("Factura confirmada", "No puede modificar una factura confirmada.") if state_was == "Confirmado" && changed?
	end

	def cliente_habilitado
	  errors.add("Cliente", "El cliente seleccionado está inhabilitado para operaciones.") unless client && client.enabled?
	end

  def fecha_de_servicio
    unless concepto == "Productos"
      errors.add(:fch_serv_desde, "Debe ingresar la fecha de inicio del servicio.") if self.fch_serv_desde.blank?
      errors.add(:fch_serv_hasta, "Debe ingresar la fecha de finalización del servicio.") if self.fch_serv_hasta.blank?
      errors.add(:fch_vto_pago, "Debe ingresar la fecha de vencimiento ") if self.fch_vto_pago.blank?
    end
  end

	def tipo_de_comprobante_habilitado
    errors.add(:cbte_tipo, "Tipo de comprobante inválido para la transaccíon.") unless InvoiceManager::CbteTypesGetter.call(self.company, self.client).map{|k,v| v}.include?(cbte_tipo)
  end
  #VALIDACIONES

	#FUNCIONES
		def editable?
			self.state == "Pendiente"
		end

		def confirmado?
			["Confirmado", "Anulado", "Anulado parcialmente"].include?(self.state)
		end

		def totalmante_anulado?
		  self.state == "Anulado"
		end

		def parcialmente_anulado?
		  self.state == "Anulado parcialmente"
		end

		def anulado?
			["Anulado", "Anulado parcialmente"].include?(self.state)
		end

		def is_invoice?
      COD_INVOICE.include?(cbte_tipo) || cbte_tipo.nil?
    end

    def is_credit_note?
      COD_NC.include?(cbte_tipo)
    end

    def is_debit_note?
      COD_ND.include?(cbte_tipo)
    end

		def set_expired!
		  update_columns(expired: true)
		end

		def entregado!
		  update_columns(delivered: true)
		end

		def no_entregado!
		  update_columns(delivered: false)
		end

    def authorized_invoice?
      (self.cae.length > 0) && (self.company.environment == "production")
    end

    def tipo
      InvoiceManager::CbteTypeGetter.call(self)
    end

    def destroy(mode = :soft)
      if self.editable?
        update_column(:active, false)
        run_callbacks :destroy
        freeze
      else
        if mode == :soft
          errors.add(:state, "No se puede eliminar esta factura.")
        else
          super()
        end
      end
    end

    def impact_stock_if_cn
			if self.is_credit_note? && self.confirmado?
	      self.invoice_details.each do |id|
	        id.impact_stock_cn
	      end
			end
    end

    def check_cancelled_state_of_invoice
			if self.confirmado? && self.is_credit_note? && !self.invoice
	      total_cancellation = true
	      associated_invoice = self.invoice
	      associated_invoice.invoice_details.each do |id|
	        count = 0
	        associated_invoice.credit_notes.each do |cn|
						count = cn.invoice_details
							.where(product_id: id.product_id)
							.pluck(:quantity)
							.inject(count) { |sum, n| sum + n }
	        end

	        total_cancellation = false if count != id.quantity
				end
	      if total_cancellation
	        associated_invoice.update_column(:state, "Anulado")
				else
					associated_invoice.update_column(:state, "Anulado parcialmente")
	      end
			end
    end

    def update_payment_belongs
      income_payments.each do |p|
        p.update_column(:user_id, self.user_id) if p.user_id.blank?
        p.update_column(:company_id, self.company_id) if p.company_id.blank?
      end
    end

		def total_left
      (total.to_f - total_pay.to_f).round(2)
		end

    def real_total
      if is_invoice? || is_debit_note?
        self.total.round(2) - self.credit_notes.sum(:total).round(2) + self.credit_notes.sum(:total_pay).round(2)
      elsif is_credit_note?
				0
      end
    end

    def real_total_left
      (real_total - total_pay).round(2)
    end

		def real_total_including_debit_notes
      if is_invoice?
        self.total.round(2) - self.credit_notes.sum(:total).round(2) + self.credit_notes.sum(:total_pay).round(2) + self.debit_notes.sum(:total).round(2) - self.debit_notes.sum(:total_pay).round(2)
      else
        self.total.round(2)
      end
    end

		def real_total_left_including_debit_notes
      (real_total_including_debit_notes - total_pay).round(2)
    end

    def stock_between_invoice_and_credit_notes
			if self.is_credit_note? || self.editable?
	      unless self.associated_invoice.nil?
					#anulada_totalmente = true
	        invoice = self.invoice
	        invoice.invoice_details.each do |invoice_detail|
	          invoice_product     = invoice_detail.product
	          invoice_quantity    = invoice_detail.quantity
	          cn_detail_quantity  = 0

	          invoice.credit_notes.each do |credit_note|
	            credit_note.invoice_details.where(product_id: invoice_product.id).each do |cn_detail|
	              cn_detail_quantity += cn_detail.quantity
	            end
	          end

	          self.invoice_details.each { |cn_detail| cn_detail_quantity += cn_detail.quantity if cn_detail.product_id == invoice_product.id }
						errors.add(:quantity, "La cantidad ingresada de uno o más de los productos supera a la cantidad de la factura inicial asociada.") if cn_detail_quantity > invoice_quantity
	        end
	      end
			end
    end

    def delete_barcode path
      File.delete(path) if File.exist?(path)
    end
    handle_asynchronously :delete_barcode, :run_at => Proc.new { 5.seconds.from_now }

    def custom_save send_to_afip = false
      response = self.save
      confirm_invoice(response, send_to_afip)
      return response && !self.errors.any?
    end

		def confirm_invoice(response, send_to_afip)
			if response && send_to_afip == "true"
				InvoiceManager::Confirmator.call(self)
      end
		end

    def update_total_pay
      update_column(:total_pay, sum_payments)
    end

    def touch_payments
      income_payments.each{ |p| p.run_callbacks(:save) }
    end

    def set_invoice_activity
      UserActivity.create_for_confirmed_invoice(self)
    end

    def activate_commissions
      commissioners.update_all(active: true)
    end

    def touch_commissioners
      self.commissioners.each { |c| c.run_callbacks(:save) }
    end
  #PROCESOS

  def client
    Client.unscoped{ super }
  end

	def client_name
		client.nil? ? "Sin nombre" : client.name
	end

	def client_document
		client.nil? ? 0 : client.document_number
	end

	def client_iva_cond
		client.nil? ? "Consumidor Final" : client.iva_cond
	end

  def confirmed_notes
    notes.where(state: "Confirmado")
  end

  def sum_payments
    self.income_payments.sum(:total)
  end

  def cbte_fch
    fecha = read_attribute("cbte_fch")
    fecha.blank? ? nil : I18n.l(fecha.to_date)
  end

  def invoice_comp_number
    invoice.nil? ? "" : invoice.comp_number
  end

  def nombre_comprobante
    case cbte_tipo
    when *COD_INVOICE
      "Factura"
    when *COD_ND
      "Nota de Débito"
    when *COD_NC
      "Nota de Crédito"
    end
  end

  def full_number
		return "Falta confirmar" if editable?
		"#{sale_point.name} - #{comp_number}"
  end

  def full_number_with_debt
		return "Falta confirmar" if editable?
		"#{nombre_comprobante.split().map{|w| w.first unless w.first != w.first.upcase}.join()}: #{sale_point.name} - #{comp_number} - Total: $#{total} - Faltante: $#{real_total_left} "
  end

  def full_number_with_nc_and_nd
		return "Falta confirmar" if editable?
		"#{nombre_comprobante.split().map{|w| w.first unless w.first != w.first.upcase}.join()}: #{sale_point.name} - #{comp_number} - Total: $#{total} - Faltante: $#{real_total_left_including_debit_notes} "
  end

  def full_name
    "Pto. venta: #{sale_point.name}.  Número: #{comp_number || 'Sin confirmar'}. Total: #{total}. Fecha: #{cbte_fch}."
  end

  def name
    full_number
  end

  def name_with_comp
    return "Nota de crédito: #{full_number}" if is_credit_note?
    return "Nota de débito: #{full_number}" if is_debit_note?
    "Factura: #{full_number}"
  end

  def type_of_model
    "invoice"
  end
end
