class Invoice < ApplicationRecord
	belongs_to :client
	belongs_to :sale_point
	belongs_to :company
	belongs_to :user
  belongs_to :invoice, foreign_key: :associated_invoice, optional: true
  belongs_to :budget, optional: true
  belongs_to :sales_file, optional: true

  default_scope { where(active: true) }
  scope :only_invoices, -> { where(cbte_tipo: COD_INVOICE) }
  scope :unassociated_invoices, -> { where(associated_invoice: nil) }
  scope :debit_notes, -> { where(cbte_tipo: COD_ND).where(state: "Confirmado") }
  scope :credit_notes, -> { where(cbte_tipo: COD_NC).where(state: "Confirmado") }

  has_many :notes, foreign_key: :associated_invoice, class_name: 'Invoice'
  has_many :debit_notes, -> { debit_notes }, foreign_key: :associated_invoice, class_name: 'Invoice'
  has_many :credit_notes, -> { credit_notes }, foreign_key: :associated_invoice, class_name: 'Invoice'
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


	STATES = ["Pendiente", "Pagado", "Confirmado", "Anulado", "Anulado parcialmente"]
  COD_INVOICE = ["01", "06", "11"]
  COD_ND = ["02", "07", "12"]
  COD_NC = ["03", "08", "13"]

	before_validation 				:check_if_confirmed
	before_validation         :stock_between_invoice_and_credit_notes, if: Proc.new{ |i| i.is_credit_note? || i.state == "Pendiente" }
	validates_presence_of 		:client_id, message: "El comprobante debe estar asociado a un cliente."
	validates	 								:total, presence: { message: "El total no debe estar en blanco." },
																		numericality: { greater_than_or_equal_to: 0.0, message: "El total debe ser mayor o igual a 0." }
	validates_presence_of 		:total_pay, message: "El total pagado no debe estar en blanco."
	validates_presence_of 		:sale_point_id, message: "El punto de venta no debe estar en blanco."
	validates_inclusion_of 		:state, in: STATES, message: "Estado inválido."
	validates_uniqueness_of 	:associated_invoice, scope: [:company_id, :active, :cbte_tipo, :state], allow_blank: true, if: Proc.new{|i| i.state == "Pendiente"}
	validate 									:at_least_one_detail
	validate 									:cbte_tipo_inclusion
	validate 									:fch_ser_if_service

	before_save 	:old_real_total_left, if: Proc.new{ |i| i.is_credit_note? } #sólo para notas de crédito
	after_create 	:create_sales_file, if: Proc.new{|b| b.sales_file.nil? && !b.budget.nil?}
	after_save 		:set_state, :touch_commissioners, :touch_payments, :touch_account_movement, :update_payment_belongs
  after_save 		:create_iva_book, if: Proc.new{|i| i.state == "Confirmado"} #FALTA UN AFTER SAVE PARA CUANDO SE ANULA
  after_save 		:set_invoice_activity, if: Proc.new{|i| (i.state == "Confirmado" || i.state == "Anulado") && (i.changed?)}
  after_save 		:update_expired, :check_receipt, if: Proc.new{|i| i.state == "Confirmado"}
	## A SERVICIO
  after_save 		:impact_stock_if_cn ##para que impacte en stock con los detalles del producto
  after_save 		:check_cancelled_state_of_invoice, if: Proc.new{ |i| i.confirmado? && i.is_credit_note? && !i.associated_invoice.nil?}
	after_touch 	:update_total_pay
  before_destroy :check_if_editable
  #validates_inclusion_of :sale_point_id, in: Afip::BILL.get_sale_points FALTA TERMINAR EN LA GEMA

	#FILTROS DE BUSQUEDA
  	def self.search_by_client name
  		if not name.blank?
  			joins(:client).where("clients.name ILIKE ?", "%#{name}%")
  		else
  			all
  		end
  	end

  	def self.search_by_tipo tipo
  		if not tipo.blank?
  			where(cbte_tipo: tipo)
  		else
  			all
  		end
 	  end

  	def self.search_by_state state
  		if not state.blank?
  			where(state: state)
  		else
  			all
  		end
  	end

    def self.search_by_number comp_number
      if not comp_number.blank?
        where("comp_number ILIKE ?", "%#{comp_number}%")
      else
        all
      end
    end
	#FILTROS DE BUSQUEDA

  #VALIDACIONES
    def check_if_editable
      errors.add(:base, "No puede modificar un comprobante confirmado.") unless editable?
      valid?
    end

    def at_least_one_detail
			errors.add(:base, "El comprobante debe tener al menos 1 (un) concepto") unless self.invoice_details.reject(&:marked_for_destruction?).count > 0
    end

    def fch_ser_if_service
      unless concepto == "Productos"
        errors.add(:fch_serv_desde, "Debe ingresar la fecha de inicio del servicio.") if self.fch_serv_desde.blank?
        errors.add(:fch_serv_hasta, "Debe ingresar la fecha de finalización del servicio.") if self.fch_serv_hasta.blank?
        errors.add(:fch_vto_pago, "Debe ingresar la fecha de vencimiento ") if self.fch_vto_pago.blank?
      end
    end

		def cbte_tipo_inclusion
      errors.add(:cbte_tipo, "Tipo de comprobante inválido para la transaccíon.") unless available_cbte_type.map{|k,v| v}.include?(cbte_tipo)
    end
  #VALIDACIONES

	#FUNCIONES
		def total_left
      return (total.to_f - total_pay.to_f).round(2)
		end

		def editable?
			state != 'Confirmado' && state != 'Anulado' && state != 'Anulado parcialmente'
		end

    def check_authorized_invoice
      (self.cae.length > 0) && (self.company.environment == "production")
    end

    def net_amount_sum
			return invoice_details.where(iva_aliquot: ["03", "04", "05", "06"]).inject(0) {|sum, detail| sum + detail.neto }.round(2)
    end

    def iva_amount_sum
			total_calculado = self.invoice_details.inject(0) {|sum, detail| sum + detail.iva_amount}
			total_calculado -= self.bonification
			total_calculado = self.bonifications.inject(total_calculado) {|sum, bonification| sum - bonification.amount}
			return total_calculado
    end

    def self.available_cbte_type(company, client)
      Afip::CBTE_TIPO.map{|k,v| [v, k] if Afip::AVAILABLE_TYPES[company.iva_cond_sym][client.iva_cond_sym].include?(k)}.compact
    end

    def available_cbte_type
      Afip::CBTE_TIPO.map{|k,v| [v, k] if Afip::AVAILABLE_TYPES[company.iva_cond_sym][client.iva_cond_sym].include?(k)}.compact
    end

    def tipo
      Afip::CBTE_TIPO[cbte_tipo]
    end

    def destroy(mode = :soft)
      if self.state == "Pendiente" || self.state == "Pagado" ##editable?
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

    def check_if_confirmed
      if state_was == "Confirmado" && changed?
        errors.add("Factura confirmada", "No puede modificar una factura confirmada.")
      end
    end

		def confirmado?
		  self.state == "Confirmado"
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

    def update_expired
      if (Date.today - self.cbte_fch.to_date).to_i >= 30 && (self.total - self.total_pay > 0)
        self.expired = true
      end
    end
    handle_asynchronously :update_expired, :run_at => Proc.new { |invoice| invoice.cbte_fch.to_date + 30.days }
	#FUNCIONES

  #PROCESOS
    def impact_stock_if_cn
			if self.confirmado? && self.is_credit_note?
	      self.invoice_details.each do |id|
	        id.impact_stock_cn
	      end
			end
    end

    def check_cancelled_state_of_invoice
      total_cancellation = true
      associated_invoice = Invoice.find(self.associated_invoice)
      associated_invoice.invoice_details.each do |id|
        id_product = id.product
        id_quantity = id.quantity
        count = 0
        associated_invoice.credit_notes.each do |cn|
          cn.invoice_details.where(product_id: id_product.id).each do |cn_id|
            count += cn_id.quantity
          end
        end
        if count != id_quantity
          total_cancellation = false
        end
      end
      if total_cancellation
        associated_invoice.update_column(:state, "Anulado")
			else
				associated_invoice.update_column(:state, "Anulado parcialmente")
      end
    end

    def update_payment_belongs
      income_payments.each do |p|
        p.update_column(:user_id, self.user_id) unless !p.user_id.blank?
        p.update_column(:company_id, self.company_id) unless !p.company_id.blank?
      end
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

          self.invoice_details.each do |cn_detail|
            if cn_detail.product_id == invoice_product.id
              cn_detail_quantity += cn_detail.quantity
            end
          end
					if cn_detail_quantity > invoice_quantity
						errors.add(:quantity, "La cantidad ingresada de uno o más de los productos supera a la cantidad de la factura inicial asociada.")
					elsif cn_detail_quantity < invoice_quantity
						#ACTUALIZA LA FACTURA A ANULADA parcialmente
						#anulada_totalmente = false
					end
        end
      end
    end

    def create_sales_file
      if sales_file_id.nil?
        if budget_id.nil?
          sf = SalesFile.create(
            company_id: company_id,
            client_id: client_id,
            responsable_id: user_id
          )
          update_column(:sales_file_id, sf.id)
        else
          update_column(:sales_file_id, budget.sales_file_id)
        end
      end
    end

    def create_iva_book
      IvaBook.add_from_invoice(self)
    end

    def delete_barcode path
       File.delete(path) if File.exist?(path)
    end
    handle_asynchronously :delete_barcode, :run_at => Proc.new { 5.seconds.from_now }

    def set_state
      if editable? && (total.to_f > 0.0) && (total.to_f <= total_pay.to_f)
				update_column(:state, "Pagado")
      end
    end

    def set_client params
      if params[:client][:iva_cond] != "Consumidor Final"
        client              = company.clients.where(document_number: params[:client][:document_number], document_type: params[:client][:document_type]).first_or_initialize
        client.name         = params[:client][:name]
        client.birthday     = params[:client][:birthday]
        client.phone        = params[:client][:phone]
        client.mobile_phone = params[:client][:mobile_phone]
        client.email        = params[:client][:email]
        client.address      = params[:client][:address]
        client.iva_cond     = params[:client][:iva_cond]
        if client.save
          self.update_column(:client_id, client.id)
        end
      end
    end

    def update params, send_to_afip = false
      response = super(params)
      confirm_invoice(response, send_to_afip)
      return response && !self.errors.any?
    end

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

    def check_receipt
      Receipt.create_from_invoice(self) if self.confirmado? && self.income_payments.any? && self.receipts.empty?
    end

    def update_total_pay
      update_column(:total_pay, sum_payments)
      set_state
    end

		def old_real_total_left
			if self.invoice ##tiene comprobante asociado
				@old_real_total_left = self.invoice.real_total_left
			end
		end

    def check_delivery_note_quantity_left?
      a_entregar = invoice_details.joins(:product).where("products.tipo = 'Producto'").map(&:quantity).inject(0) {|suma, quantity| suma + quantity}
      delivered = 0
      self.delivery_notes.where(state: "Finalizado").each do |dn|
        delivered += dn.delivery_note_details.map(&:quantity).inject(0) { |suma, quantity| suma + quantity }
      end

      if a_entregar > delivered
        return true
      end
      return false
    end

    def touch_account_movement
      AccountMovement.create_from_invoice(self, @old_real_total_left)
    end

    def touch_payments
      income_payments.map{|p| p.run_callbacks(:save)}
    end

    def set_invoice_activity
      UserActivity.create_for_confirmed_invoice(self)
    end

    def activate_commissions
      commissioners.update_all(active: true)
    end

    def touch_commissioners
      self.commissioners.map{|c| c.run_callbacks(:save)}
    end
  #PROCESOS

	#ATRIBUTOS
    # def client
    #   Client.unscoped{ super }
    # end

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

    def sum_tributes
      self.tributes.sum(:importe)
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
      when "01", "06", "11"
        "Factura"
      when "02", "07", "12"
        "Nota de Débito"
      when "03", "08", "13"
        "Nota de Crédito"
      end
    end

    def full_number
      if state == "Confirmado" || state == "Anulado" || state == "Anulado parcialmente"
        "#{sale_point.name} - #{comp_number}"
      else
        "Falta confirmar"
      end
    end

    def full_number_with_debt
      if state == "Confirmado" || state == "Anulado" || state == "Anulado parcialmente"
        "#{nombre_comprobante.split().map{|w| w.first unless w.first != w.first.upcase}.join()}: #{sale_point.name} - #{comp_number} - Total: $#{total} - Faltante: $#{real_total_left} "
      else
        "Falta confirmar"
      end
    end

    def full_number_with_nc_and_nd
      if state == "Confirmado" || state == "Anulado" || state == "Anulado parcialmente"
        "#{nombre_comprobante.split().map{|w| w.first unless w.first != w.first.upcase}.join()}: #{sale_point.name} - #{comp_number} - Total: $#{total} - Faltante: $#{real_total_left_including_debit_notes} "
      else
        "Falta confirmar"
      end
    end

    def full_name
      "Pto. venta: #{sale_point_name}.  Número: #{comp_number || 'Sin confirmar'}. Total: #{total}. Fecha: #{cbte_fch}."
    end

    def name
      if comp_number.nil?
        "Sin confirmar"
      else
        "#{sale_point_name} - #{comp_number}"
      end
    end

    def sale_point_name
      sale_point.name
    end

    def name_with_comp
      if is_credit_note?
        "Nota de crédito: #{name}"
      elsif is_debit_note?
        "Nota de débito: #{name}"
      else
        "Factura: #{name}"
      end
    end

    def type_of_model
      "invoice"
    end
	#ATRIBUTOS

  #AFIP
    def code_hash
      {
        cuit: self.company.cuit,
        cbte_tipo: self.cbte_tipo.to_s.rjust(3,padstr= '0'),
        pto_venta: self.sale_point.name,
        cae: self.cae,
        vto_cae: self.cae_due_date
      }
    end

    def code_numbers(code_hash)
      require "check_digit.rb"
      code 				= code_hash.values.join("")
      last_digit 	= CheckDigit.new(code).calculate
      result 			= "#{code}#{last_digit}"
      result.size.odd? ? "0" + result : result
    end
  #AFIP

  def fill_comp_number
    unless self.comp_number.nil?
      self.comp_number.to_s.rjust(8,padstr= '0')
    end
  end

  def all_payments_string
		array = []
    if self.receipts.any?
      self.receipts.each do |receipt|
        receipt.account_movement.account_movement_payments.user_payments.each do |payment|
          array << payment.payment_name
        end
      end
      return array.uniq.compact.join(', ')
    else
      return "Cta. Cte."
    end
  end
end
