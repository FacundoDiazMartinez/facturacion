class Invoice < ApplicationRecord
  	belongs_to :client
  	belongs_to :sale_point
  	belongs_to :company
  	belongs_to :user

    default_scope {where(active:true)}


    has_many :payments
    has_many :invoice_details, dependent: :destroy
    has_many :products, through: :invoice_details
    has_many :iva_books

    has_one  :receipt
    has_one  :account_movement

    accepts_nested_attributes_for :payments, allow_destroy: true, reject_if: :all_blank
    accepts_nested_attributes_for :invoice_details, allow_destroy: true, reject_if: :all_blank
    accepts_nested_attributes_for :client, reject_if: :all_blank

    after_save :set_state
    after_save :touch_account_movement, if: Proc.new{|i| i.saved_change_to_total?}
    after_save :create_iva_book, if: Proc.new{|i| i.state == "Confirmado"} #FALTA UN AFTER SAVE PARA CUANDO SE ANULA

  	STATES = ["Pendiente", "Pagado", "Confirmado", "Anulado"]

    validates_presence_of :client_id, message: "El comprobante debe estar asociado a un cliente."
    validates_presence_of :total, message: "El total no debe estar en blanco."
    validates_presence_of :total_pay, message: "El total pagado no debe estar en blanco."
    validates_presence_of :sale_point_id, message: "El punto de venta no debe estar en blanco."
    validates_inclusion_of :state, in: STATES, message: "Estado inválido."


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

      def available_cbte_type
        pp self.company.iva_cond_sym
        pp self.client.iva_cond_sym
        pp Afip::CBTE_TIPO.select{|k,v| k == Afip::BILL_TYPE[self.company.iva_cond_sym][self.client.iva_cond_sym]}.map{|k,v| [v,k]}
      end

      def tipo
        Afip::CBTE_TIPO[cbte_tipo]
      end
  	#FUNCIONES

    #PROCESOS
      def create_iva_book
        IvaBook.add_from_invoice(self)
      end

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

      def destroy
        update_column(:active,false)
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
          if response && send_to_afip
            get_cae
          end
          return response && !self.errors.any?
      end

      def touch_account_movement
        if cbte_tipo != nil
          am              = AccountMovement.where(invoice_id: id).first_or_initialize
          am.client_id    = client_id
          am.invoice_id   = id
          am.cbte_tipo    = Afip::CBTE_TIPO[cbte_tipo]
          am.debe         = true
          am.haber        = false
          am.total        = total.to_f
          am.saldo        = (client.saldo.to_f + am.total) unless !am.new_record?
          am.save
        end
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
        self.payments.sum(:total)
      end

      def cbte_fch
        fecha = read_attribute("cbte_fch")
        fecha.blank? ? nil : I18n.l(fecha.to_date)
      end
  	#ATRIBUTOS


    #AFIP
      #FUNCIONES
      def set_constants
        if self.company.environment == "production"
          #PRODUCCION
          Afip.pkey               = "#{Rails.root}/app/afip/facturacion.key"
          Afip.cert               = "#{Rails.root}/app/afip/pedido.crt"
          Afip.auth_url     = "https://wsaa.afip.gov.ar/ws/services/LoginCms"
          Afip.service_url    = "https://servicios1.afip.gov.ar/wsfev1/service.asmx?WSDL"
          Afip.cuit         = self.company.cuit || raise(Afip::NullOrInvalidAttribute.new, "Please set CUIT env variable.")
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
        Afip.default_moneda   = self.company.moneda.parameterize.underscore.gsub(" ", "_").to_sym
        Afip.own_iva_cond     = self.company.iva_cond.parameterize.underscore.gsub(" ", "_").to_sym
      end

      def set_bill
        set_constants
        bill = Afip::Bill.new(
          net:        self.net_amount_sum,
          doc_num:    self.client.document_number,
          sale_point: self.sale_point.name,
          documento:  Afip::DOCUMENTOS.key(self.client.document_type),
          moneda:     self.company.moneda.parameterize.underscore.gsub(" ", "_").to_sym,
          iva_cond:   self.client.iva_cond.parameterize.underscore.gsub(" ", "_").to_sym,
          concepto:   self.concepto,
          ivas:       self.iva_array,
          cbte_type:  self.cbte_tipo
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
        pp bill.response
        return bill
      end

      def get_cae
        if state == "Pagado"
          auth_bill(set_bill)
        else
          errors.add(:state, "La factura debe estar pagada antes de enviarse a A.F.I.P.")
        end
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
          self.update(
            cae: bill.response.cae,
            cae_due_date: bill.response.cae_due_date,
            cbte_fch: bill.response.cbte_fch.to_date,
            authorized_on: bill.response.authorized_on.to_time,
            comp_number: bill.response.cbte_hasta.to_s.rjust(8,padstr= '0'),
            state: "Confirmado"
          )
        end
      #PROCESOS
    #AFIP
end
