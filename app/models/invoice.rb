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

  accepts_nested_attributes_for :income_payments, allow_destroy: true, reject_if: Proc.new{|ip| ip["type_of_payment"].blank?}
  accepts_nested_attributes_for :invoice_details, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :tributes, allow_destroy: true, reject_if: Proc.new{|t| t["afip_id"].blank?}
  accepts_nested_attributes_for :client, reject_if: :all_blank
  accepts_nested_attributes_for :bonifications, allow_destroy: true, reject_if: :all_blank

  after_save :set_state, :touch_commissioners, :touch_payments, :touch_account_movement, :check_receipt,  :update_payment_belongs
  after_touch :update_total_pay #, :touch_account_movement, :check_receipt
	before_save :old_real_total_left, if: Proc.new{|i| i.is_credit_note?}

  after_save :create_iva_book, if: Proc.new{|i| i.state == "Confirmado"} #FALTA UN AFTER SAVE PARA CUANDO SE ANULA
  after_save :set_invoice_activity, if: Proc.new{|i| (i.state == "Confirmado" || i.state == "Anulado") && (i.changed?)}
  after_save :update_expired, if: Proc.new{|i| i.state == "Confirmado"}
  #after_save :rollback_stock, if: Proc.new{|i| i.state == "Confirmado" && i.saved_change_to_state? && i.is_credit_note? && i.invoice.delivery_notes.empty?} >>> Reeplazado por :impact_stock_if_cn
  after_save :impact_stock_if_cn, if: Proc.new{|i| i.state == "Confirmado" && i.is_credit_note?}
  after_save :check_cancelled_state_of_invoice, if: Proc.new{ |i| i.state == "Confirmado" && i.is_credit_note? && !i.associated_invoice.nil?}

  before_validation :check_if_confirmed
  before_destroy :check_if_editable
  after_create :create_sales_file, if: Proc.new{|b| b.sales_file.nil? && !b.budget.nil?}

	STATES = ["Pendiente", "Pagado", "Confirmado", "Anulado", "Anulado parcialmente"]
  COD_INVOICE = ["01", "06", "11"]
  COD_ND = ["02", "07", "12"]
  COD_NC = ["03", "08", "13"]

  validates_presence_of :client_id, message: "El comprobante debe estar asociado a un cliente."
  #validates_presence_of :associated_invoice, message: "El comprobante debe estar asociado a un documento a aular.", if: Proc.new{ |i| not i.is_invoice?}
  validates_presence_of :total, message: "El total no debe estar en blanco."
  validates_numericality_of :total, greater_than_or_equal_to: 0.0, message: "El total debe ser mayor o igual a 0."
  validates_presence_of :total_pay, message: "El total pagado no debe estar en blanco."
  validates_presence_of :sale_point_id, message: "El punto de venta no debe estar en blanco."
  validates_inclusion_of :state, in: STATES, message: "Estado inválido."
  validate :cbte_tipo_inclusion
  validate :at_least_one_detail, if: Proc.new{ |i| i.state_was == "Pendiente" && (i.state == "Pagado" || i.state == "Confirmado" )}
  validate :fch_ser_if_service
  validates_uniqueness_of :associated_invoice, scope: [:company_id, :active, :cbte_tipo, :state], allow_blank: true, if: Proc.new{|i| i.state == "Pendiente"}
  validates_numericality_of :bonification, :greater_than => -100, :less_than => 100

  TRIBUTOS = [
   ["Impuestos nacionales", "1"],
   ["Impuestos provinciales", "2"],
   ["Impuestos municipales", "3"],
   ["Impuestos Internos", "4"],
   ["Otro", "99"],
   ["IIBB", "5"],
   ["Percepción de IVA", "6"],
   ["Percepción de IIBB", "7"],
   ["Percepciones por Impuestos Municipales", "8"],
   ["Otras Percepciones", "9"],
   ["Percepción de IVA a no Categorizado", "13"]
   ]

  #validates_inclusion_of :sale_point_id, in: Afip::BILL.get_sale_points FALTA TERMINAR EN LA GEMA



  # TABLA
  # create_table "invoices", force: :cascade do |t|
  #   t.boolean "active"
  #   t.bigint "client_id"
  #   t.string "state", default: "Pendiente", null: false
  #   t.float "total", default: 0.0, null: false
  #   t.float "total_pay", default: 0.0, null: false
  #   t.string "header_result"
  #   t.string "authorized_on"
  #   t.string "cae_due_date"
  #   t.string "cae"
  #   t.string "cbte_tipo"
  #   t.bigint "sale_point_id"
  #   t.string "concepto"
  #   t.string "cbte_fch"
  #   t.float "imp_tot_conc", default: 0.0, null: false
  #   t.float "imp_op_ex", default: 0.0, null: false
  #   t.float "imp_trib", default: 0.0, null: false
  #   t.float "imp_neto", default: 0.0, null: false
  #   t.float "imp_iva", default: 0.0, null: false
  #   t.float "imp_total", default: 0.0, null: false
  #   t.integer "cbte_hasta"
  #   t.integer "cbte_desde"
  #   t.string "iva_cond"
  #   t.string "comp_number"
  #   t.bigint "company_id"
  #   t.bigint "user_id"
  #   t.datetime "created_at", null: false
  #   t.datetime "updated_at", null: false
  #   t.bigint "associated_invoice"
  #   t.date "fch_serv_desde"
  #   t.date "fch_serv_hasta"
  #   t.index ["client_id"], name: "index_invoices_on_client_id"
  #   t.index ["company_id"], name: "index_invoices_on_company_id"
  #   t.index ["sale_point_id"], name: "index_invoices_on_sale_point_id"
  #   t.index ["user_id"], name: "index_invoices_on_user_id"
  # end
  # TABLA


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
      errors.add(:base, "No puede eliminar una factura confirmada") unless editable?
      errors.blank?
    end

    def at_least_one_detail
      # when creating a new invoice: making sure at least one detail exists
      return errors.add :base, "Debe tener al menos un concepto" unless invoice_details.length > 0

      # when updating an existing invoice: Making sure that at least one detail would exist
      return errors.add :base, "Debe tener al menos un concepto" if invoice_details.reject{|invoice_detail| invoice_detail._destroy == true}.empty?
    end

    def fch_ser_if_service
      unless concepto == "Productos"
        errors.add(:fch_serv_desde, "Debe ingresar la fecha de inicio del servicio.") unless !self.fch_serv_desde.blank?
        errors.add(:fch_serv_hasta, "Debe ingresar la fecha de finalización del servicio.") unless !self.fch_serv_hasta.blank?
        errors.add(:fch_vto_pago, "Debe ingresar la fecha de vencimiento ") unless !self.fch_vto_pago.blank?
      end
    end
  #VALIDACIONES


	#FUNCIONES

    # def income_payments_attributes=(attributes)
    #   attributes.each do |num, c|
    #     if c["_destroy"] == "false"
    #       pay = self.income_payments.where(id: c[:id]).first_or_initialize
    #       pay.credit_card_id = c.delete("credit_card_id")
    #       pay.type_of_payment = c.delete("type_of_payment")
    #       pay.total = c.delete("total")
    #       pay.payment_date = c.delete("payment_date")
    #       self.payment = pay
    #       super
    #     else
    #       payment = self.income_payments.where(id: c[:id]).first
    #       if !payment.nil?
    #         payment.destroy
    #       end
    #     end
    #   end
    # end

		def total_left
			left = total.to_f - total_pay.to_f
      return left.round(2)
		end

		def editable?
			state != 'Confirmado' && state != 'Anulado' && state != 'Anulado parcialmente'
		end

    def iva_array
      i = Array.new
      iva_hash = invoice_details.all.group_by{|i_d| i_d.iva_aliquot}.map{|aliquot, inv_det| {aliquot:aliquot, net_amount: inv_det.sum{|id| id.neto}, iva_amount: inv_det.sum{|s| s.iva_amount}}}
      iva_hash.each do |iva|
        i << [ iva[:aliquot], iva[:net_amount].round(2), iva[:iva_amount].round(2) ]
      end
      return i
    end

    def check_authorized_invoice
      if (self.cae.length > 0) && (self.company.environment == "production")
        return true
      else
        return false
      end
    end

    def self.applicable_iva_for_detail(aliquot)
      case aliquot
      when nil
       return 0
      when 0.0
        return 0
      when 10.5
        return 1
      when 21.0
        return 2
      when 27.0
        return 3
      end
    end

    def net_amount_sum
      total = 0
      invoice_details.where(iva_aliquot: ["03", "04", "05", "06"]).each do |detail|
        total += detail.neto
      end
      return total.round(2)
    end

    def iva_amount_sum
      total = 0
      invoice_details.each do |detail|
        total += detail.iva_amount.to_f.round(2)
      end
      if bonification != 0
        total -= total * (bonification / 100)
      end
      self.bonifications.each do |bon|
        total -= total * (bon.percentage / 100)
      end
      return total
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
      if self.state == "Pendiente" || self.state == "Pagado"
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
        errors.add(:state, "No se puede actualizar una factura confirmada.")
      end
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
      if ((Date.today - self.cbte_fch.to_date).to_i >= 30 && (self.total - self.total_pay > 0))
        self.expired = true
      end
    end
    handle_asynchronously :update_expired, :run_at => Proc.new { |invoice| invoice.cbte_fch.to_date + 30.days }

		def get_product_quantity_not_delivered product_id
			product = Product.unscoped.find(product_id)
			required_quantity = 0
			self.invoice_details.where(product_id: product.id).each do |id|
				required_quantity += id.quantity
			end
			delivered_quantity = 0
			self.delivery_notes.where(state: "Finalizado").each do |dn|
				dn.delivery_note_details.where(product_id: product.id).each do |dnd|
					delivered_quantity += dnd.quantity
				end
			end
			not_delivered = required_quantity.to_f - delivered_quantity.to_f
			return not_delivered
		end
	#FUNCIONES

  #PROCESOS

    def get_default_tributes
      company.default_tributes.each do |trib|
        tributes.build(afip_id: trib.tribute_id,
          desc: Invoice::TRIBUTOS.map{|t| t.first if t.last == "1"}.compact.first,
          base_imp: total.to_f.round(2),
          # base_imp: 0,
          alic: trib.default_aliquot
        )
      end
      return tributes
    end

    # def rollback_stock
    #   invoice_details.each do |detail|
    #     detail.remove_reserved_stock
    #   end
    # end

    def impact_stock_if_cn
      self.invoice_details.each do |id|
        id.impact_stock_cn
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
      end
    end

    def update_payment_belongs
      income_payments.each do |p|
        p.update_column(:user_id, self.user_id) unless !p.user_id.blank?
        p.update_column(:company_id, self.company_id) unless !p.company_id.blank?
      end
    end

    # def self.paid_unpaid_invoices_viejo client
    #   client.account_movements.where("account_movements.amount_available > 0.0").each do |am|
    #     if am.amount_available > 0
    #       unpaid_invoices = self.where("total > total_pay AND state = 'Confirmado' AND client_id = ?", client.id).order("cbte_fch DESC")
    #       unpaid_invoices.each_with_index do |invoice, index|
    #         if am.receipt.receipt_details.map(&:invoice_id).include? (invoice.id)
    #           pay = IncomePayment.new(type_of_payment: "6", payment_date: Date.today, invoice_id: invoice.id, generated_by_system: true, account_movement_id: am.id)
    #           pay.total = (am.amount_available.to_f >= invoice.total_left.to_f) ? invoice.total_left.to_f : am.amount_available.to_f
    #           pay.save
    #           am.update_column(:amount_available, am.amount_available - pay.total)
    #           break if am.amount_available < 1
    #         end
    #       end
    #     end
    #   end
    # end

    def self.paid_unpaid_invoices client
      client.account_movements.where("account_movements.amount_available > 0.0 AND account_movements.receipt_id IS NOT NULL").each do |am|
        am.receipt.receipt_details.each do |rd|
          if am.amount_available > 0
            invoice = rd.invoice
            unless invoice.is_credit_note?
							if invoice.real_total_left.to_f > 0
								pay = IncomePayment.new(type_of_payment: "6", payment_date: Date.today, invoice_id: invoice.id, generated_by_system: true, account_movement_id: am.id)
								pay.total = (am.amount_available.to_f >= invoice.real_total_left.to_f) ? invoice.real_total_left.to_f : am.amount_available.to_f
								pay.save
								pp pay.errors
								am.update_column(:amount_available, am.amount_available - pay.total)
							end
              break if am.amount_available < 1  # no sería mejor si <= 0 ?
            end
          end
        end
      end
    end

    def real_total
      if is_invoice?
        self.total.round(2) - self.credit_notes.sum(:total).round(2) + self.credit_notes.sum(:total_pay).round(2)
      else
        self.total.round(2)
      end
    end

    def real_total_left
      (real_total - total_pay).round(2)
    end

    def paid_invoice_from_client_debt
      result = false
      account_movements_records  = client.account_movements.joins(:invoice).where("(invoices.cbte_tipo::integer IN (#{Invoice::COD_NC.join(', ')})) AND (account_movements.amount_available > 0)")
      account_movements_records += client.account_movements.joins(:receipt).where("account_movements.amount_available > 0")
      account_movements_records.each do |am|
        @band = true
        pay = self.income_payments.new(type_of_payment: "6", payment_date: Date.today, generated_by_system: true, account_movement_id: am.id)
        pay.total = (am.amount_available.to_f >= self.real_total_left.to_f) ? self.real_total_left.to_f : am.amount_available.to_f
        result = pay.save
        @last_pay = pay
        if result
          am.update_column(:amount_available, am.amount_available - pay.total)
        else
          pay.errors
        end
        break if self.real_total_left == 0 || !result
      end
      if @band
        if result
          return {response:  true, messages: ["Se genero el pago correctamente."]}
        else
          return {response:  false, messages: ["No tiene saldo disponible para cancelar la factura."]}
        end
      else
        return {response:  false, messages: ["No tiene saldo disponible."]}
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

    def cbte_tipo_inclusion
      errors.add(:cbte_tipo, "Tipo de comprobante inválido para la transaccíon.") unless available_cbte_type.map{|k,v| v}.include?(cbte_tipo)
    end

    def create_iva_book
      IvaBook.add_from_invoice(self)
    end

    def delete_barcode path
       File.delete(path) if File.exist?(path)
    end
    handle_asynchronously :delete_barcode, :run_at => Proc.new { 5.seconds.from_now }
    # correr en consola: rake jobs:work


    def set_state
      if editable? && (total.to_f != 0.0)
        case (total.to_f <= total_pay.to_f)
        when true
          update_column(:state, "Pagado")
        when false
          update_column(:state, "Pendiente")
        end
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
        if response && send_to_afip == "true"
          get_cae
        end
        return response && !self.errors.any?
    end

    def custom_save send_to_afip = false
        response = save
        if response && send_to_afip == "true"
          get_cae
        end
        return response && !self.errors.any?
    end

    def check_receipt
      Receipt.create_from_invoice(self)
    end

    def update_total_pay
      update_column(:total_pay, sum_payments)
      set_state
    end

		def old_real_total_left
		  @old_real_total_left = self.invoice.real_total_left
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

    def sum_details
      total = 0
      self.invoice_details.map{|d| total += d.subtotal}
      if self.bonification != 0
        total -= total * (self.bonification / 100)
      end
      self.bonifications.each do |bon|
        total -= total * (bon.percentage / 100)
      end
      self.tributes.map{|t| total += t.importe}
      return total.round(2)
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
        "#{nombre_comprobante.split().map{|w| w.first unless w.first != w.first.upcase}.join()}: #{sale_point.name} - #{comp_number} - Total: $#{total} - Faltante: $#{total_left} "
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
    #FUNCIONES
    def set_constants
      if self.company.environment == "production"
        #PRODUCCION
        Afip.pkey               = "#{Rails.root}/app/afip/facturacion.key"
        Afip.cert               = "#{Rails.root}/app/afip/produccion.crt"
        Afip.auth_url           = "https://wsaa.afip.gov.ar/ws/services/LoginCms"
        Afip.service_url        = "https://servicios1.afip.gov.ar/wsfev1/service.asmx?WSDL"
        Afip.cuit               = self.company.cuit || raise(Afip::NullOrInvalidAttribute.new, "Please set CUIT env variable.")
        Afip::AuthData.environment = :production
        Afip.environment 	      = :production
        #http://ayuda.egafutura.com/topic/5225-error-certificado-digital-computador-no-autorizado-para-acceder-al-servicio/
      else
        #TEST
        Afip.cuit = "20368642682"
        Afip.pkey = "#{Rails.root}/app/afip/facturacion.key"
        Afip.cert = "#{Rails.root}/app/afip/testing.crt"
        Afip.auth_url = "https://wsaahomo.afip.gov.ar/ws/services/LoginCms"
        Afip.service_url = "https://wswhomo.afip.gov.ar/wsfev1/service.asmx?WSDL"
        Afip::AuthData.environment = :test
      end

      Afip.default_concepto   = Afip::CONCEPTOS.key(self.company.concepto)
      Afip.default_documento  = "CUIT"
      Afip.default_moneda     = self.company.moneda.parameterize.underscore.gsub(" ", "_").to_sym
      Afip.own_iva_cond       = self.company.iva_cond.parameterize.underscore.gsub(" ", "_").to_sym
    end

    def set_bill
      set_constants
      bill = Afip::Bill.new(
        net:            self.net_amount_sum,
        doc_num:        self.client.document_number,
        sale_point:     self.sale_point.name,
        documento:      Afip::DOCUMENTOS.key(self.client.document_type),
        moneda:         self.company.moneda.parameterize.underscore.gsub(" ", "_").to_sym,
        iva_cond:       self.client.iva_cond.parameterize.underscore.gsub(" ", "_").to_sym,
        concepto:       self.concepto,
        ivas:           self.iva_array,
        cbte_type:      self.cbte_tipo,
        fch_serv_desde: self.fch_serv_desde,
        fch_serv_hasta: self.fch_serv_hasta,
        due_date:       self.fch_vto_pago,
        tributos:       self.tributes.map{|t| [t.afip_id, t.desc, t.base_imp, t.alic, t.importe]},
        cant_reg:       1,
        no_gravado:     self.no_gravado,
        exento:         self.exento,
        otros_imp:      self.otros_imp

      )
      bill.doc_num = self.client.document_number
      return bill
    end

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
      code = code_hash.values.join("")
      last_digit = CheckDigit.new(code).calculate
      result = "#{code}#{last_digit}"
      result.size.odd? ? "0" + result : result
    end

    def no_gravado
      self.invoice_details.where(iva_aliquot: "01").sum(:subtotal).to_f.round(2)
    end

    def exento
      self.invoice_details.where(iva_aliquot: "02").sum(:subtotal).to_f.round(2)
    end

    def otros_imp
      self.tributes.sum(:importe).to_f.round(2)
    end

    def auth_bill bill
      bill.authorize
      if not bill.authorized?
        afip_errors(bill)
      else
        set_cae(bill)
      end
      return bill
    end

    def get_cae
      # begin
        auth_bill(set_bill)
      # rescue
      #   errors.add(:base, "Error interno de AFIP, intente nuevamente más tarde.")
      # end
    end

    def afip_errors(bill)
      if not bill.response.observaciones.nil?
        if bill.response.observaciones.any?
          if bill.response.observaciones[:obs].class == Hash
            self.errors.add(:bill, bill.response.observaciones[:obs][:msg])
          elsif bill.response.observaciones[:obs].class == Array
            bill.response.observaciones[:obs].each do |obs|
              self.errors.add(:bill, obs[:msg])
            end
          end
        end
      end
      if not bill.response.errores.nil?
        self.errors.add(:bill, bill.response.errores[:msg])
      end
    end

    def self.get_tributos company
      Afip.default_concepto = Afip::CONCEPTOS.key(company.concepto)
      Afip.default_documento = "CUIT"
      Afip.default_moneda = company.moneda.parameterize.underscore.gsub(" ", "_").to_sym
      Afip.own_iva_cond = company.iva_cond.parameterize.underscore.gsub(" ", "_").to_sym
      Afip::AuthData.environment = :test
      begin
        Afip::Bill.get_tributos.map{|t| [t[:desc], t[:id]]}
      rescue
        TRIBUTOS
      end
    end
    #FUNCIONES

    #PROCESOS
      def set_cae bill
        response = self.update(
          cae: bill.response.cae,
          cae_due_date: bill.response.cae_due_date,
          cbte_fch: bill.response.cbte_fch.to_date,
          authorized_on: bill.response.authorized_on.to_time,
          comp_number: bill.response.cbte_hasta.to_s.rjust(8,padstr= '0'),
          imp_tot_conc: bill.response.imp_tot_conc,
          imp_op_ex: bill.response.imp_op_ex,
          imp_trib: bill.response.try(:imp_trib) || 0.0,
          imp_neto: bill.response.imp_neto,
          imp_iva: bill.response.try(:imp_iva) || 0,
          imp_total: bill.response.imp_total,
          state: "Confirmado"
        )
        self.activate_commissions
        if response && !self.associated_invoice.nil? && self.is_credit_note?
          total_from_notes = self.invoice.credit_notes.sum(:total).round(2)
          if total_from_notes == self.invoice.total.round(2)
            self.invoice.update_column(:state, "Anulado")
          else
            self.invoice.update_column(:state, "Anulado parcialmente")
          end
        end
      end
    #PROCESOS
  #AFIP

  #FILL_COMP_NUMBER
  def fill_comp_number
    if !self.comp_number.nil?
      self.comp_number.to_s.rjust(8,padstr= '0')
    end
  end
  #FILL_COMP_NUMBER

  def all_payments_string
    if !self.income_payments.blank?
      pagos = []
      self.income_payments.each do |p|
        if p.type_of_payment = "06"
          pagos << {type: p.type_of_payment, name: p.payment_name_with_receipt, total: p.total}
        else
          pagos << {type: p.type_of_payment, name: p.payment_name, total: p.total}
        end
      end
      pagos =  pagos.group_by{|a| a[:name]}.map{|nom,arr| [nom,arr.map{|f| f[:total].to_f}.sum()]}
      showed_payment = ""
      pagos.each_with_index do |arr,i|
        showed_payment = showed_payment + arr[0]
        #showed_payment = showed_payment + arr[0] + ": $ " + arr[1].to_s
        if ((i+1) < pagos.count)
          showed_payment = showed_payment + " / "
        end
      end
    else
      showed_payment = "Cta. Cte."
    end

    return showed_payment

    # if !self.income_payments.nil?
    #   array_pagos = self.income_payments.map{|p| {type: p.type_of_payment, name: p.payment_name, total: p.total}}
    #   pagos_reduced = []
    #
    #   # agrupamos pagos segun tipo de pago y a continuación se suman los "totales" de cada grupo
    #   pagos_reduced << array_pagos.group_by{|a| a[:name]}.map{|nom,arr| [nom,arr.map{|f| f[:total].to_f}.sum()]}
    #
    #   showed_payment = ""
    #   pagos_reduced.first.each_with_index do |arr,i|
    #     showed_payment = showed_payment + arr[0] + ": $ " + arr[1].to_s
    #     if ((i+1) < pagos_reduced.first.count)
    #       showed_payment = showed_payment + " - "
    #     end
    #   end
    #   return showed_payment
    # end
  end


end
