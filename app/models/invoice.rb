class Invoice < ApplicationRecord
  	belongs_to :client
  	belongs_to :sale_point
  	belongs_to :company
  	belongs_to :user
    belongs_to :invoice, foreign_key: :associated_invoice, optional: true

    default_scope { where(active: true) }


    has_many :income_payments, dependent: :destroy
    has_many :invoice_details, dependent: :destroy
    has_many :products, through: :invoice_details
    has_many :iva_books, dependent: :destroy
    has_many :delivery_notes, dependent: :destroy
    has_many :commissioners, through: :invoice_details

    has_one  :receipt, dependent: :destroy
    has_one  :account_movement, dependent: :destroy

    accepts_nested_attributes_for :income_payments, allow_destroy: true, reject_if: :all_blank
    accepts_nested_attributes_for :invoice_details, allow_destroy: true, reject_if: :all_blank
    accepts_nested_attributes_for :client, reject_if: :all_blank

    after_save :set_state
    after_save :touch_commissioners
    after_save :touch_account_movement#, if: Proc.new{|i| i.saved_change_to_total?}
    after_save :touch_payments
    after_save :check_receipt, if: Proc.new{|i| i.state == "Confirmado"}
    after_save :create_iva_book, if: Proc.new{|i| i.state == "Confirmado"} #FALTA UN AFTER SAVE PARA CUANDO SE ANULA
    after_save :set_invoice_activity, if: Proc.new{|i| i.state == "Confirmado" || i.state == "Anulado"}
    before_validation :check_if_confirmed

  	STATES = ["Pendiente", "Pagado", "Confirmado", "Anulado"]

    validates_presence_of :client_id, message: "El comprobante debe estar asociado a un cliente."
    validates_presence_of :associated_invoice, message: "El comprobante debe estar asociado a un cliente.", if: Proc.new{ |i| not i.is_invoice?}
    validates_presence_of :total, message: "El total no debe estar en blanco."
    validates_numericality_of :total, greater_than_or_equal_to: 0.0, message: "El total debe ser mayor o igual a 0."
    validates_presence_of :total_pay, message: "El total pagado no debe estar en blanco."
    validates_presence_of :sale_point_id, message: "El punto de venta no debe estar en blanco."
    validates_inclusion_of :state, in: STATES, message: "Estado inválido."
    validate :cbte_tipo_inclusion

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
	  			where("clients.name ILIKE ?", "%#{name}%")
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


  	#FUNCIONES
  		def total_left
  			total.to_f - total_pay.to_f
  		end

  		def editable?
  			state != 'Confirmado' && state != 'Anulado'
  		end

      def iva_sum
        total = 0
        invoice_details.each do |detail|
          total += detail.iva_amount.to_f.round(2)
        end
        return total
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
        invoice_details.each do |detail|
          total += detail.neto
        end
        return total.round(2)
      end

      def iva_amount_sum
        total = 0
        invoice_details.each do |detail|
          total += detail.iva_amount.to_f.round(2)
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

      def destroy
        update_column(:active, false)
        run_callbacks :destroy
        freeze
      end

      def check_if_confirmed
        if state_was == "Confirmado"
          errors.add(:state, "No se puede actualizar una factura confirmada.")
        end
      end

      def is_invoice?
        ["01", "06", "11"].include?(cbte_tipo) || cbte_tipo.nil?
      end

      def is_credit_note?
        ["03", "08", "13"].include?(cbte_tipo)
      end

      def is_debit_note?
        ["02", "07", "12"].include?(cbte_tipo)
      end
  	#FUNCIONES

    #PROCESOS

      def cbte_tipo_inclusion
        errors.add(:cbte_tipo, "Tipo de comprobante inválido para la transaccíon.") unless available_cbte_type.map{|k,v| v}.include?(cbte_tipo)
      end

      def create_iva_book
        IvaBook.add_from_invoice(self)
      end

      # def created_at
      #   if not super.blank?
      #     I18n.l(super)
      #   end
      # end

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
          pp response
          pp errors
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

      def touch_account_movement
        AccountMovement.create_from_invoice(self)
      end

      def touch_payments
        pp "ENTRO AL TOUCH PAYMENTS DE INVOICE"
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
        self.invoice_details.sum(:subtotal)
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
        "#{sale_point.name} - #{comp_number}" unless not(state == "Confirmado" || state == "Anulado")
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
          due_date:       self.fch_vto_pago
        )
        bill.doc_num = self.client.document_number
        return bill
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
        auth_bill(set_bill)
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
            imp_trib: bill.response.imp_trib,
            imp_neto: bill.response.imp_neto,
            imp_iva: bill.response.imp_iva,
            imp_total: bill.response.imp_total,
            state: "Confirmado"
          )
          self.activate_commissions
          if response && !self.associated_invoice.nil?
            self.invoice.update_column(:state, "Anulado")
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
      if !self.income_payments.nil?
        array_pagos = self.income_payments.map{|p| {type: p.type_of_payment, name: p.payment_name, total: p.total}}
        pagos_reduced = []

        # agrupamos pagos segun tipo de pago y a continuación se suman los "totales" de cada grupo
        pagos_reduced << array_pagos.group_by{|a| a[:name]}.map{|nom,arr| [nom,arr.map{|f| f[:total].to_f}.sum()]}

        showed_payment = ""
        pagos_reduced.first.each_with_index do |arr,i|
          showed_payment = showed_payment + arr[0] + ": $ " + arr[1].to_s
          if ((i+1) < pagos_reduced.first.count)
            showed_payment = showed_payment + " - "
          end
        end
        return showed_payment
      end
    end
end
