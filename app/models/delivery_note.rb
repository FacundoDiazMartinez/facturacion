class DeliveryNote < ApplicationRecord

  belongs_to :company,optional: true
  belongs_to :invoice,optional: true
  belongs_to :user,optional: true
  belongs_to :client,optional: true
  belongs_to :sales_file, optional: true


  has_many :delivery_note_details, dependent: :destroy
  has_many :invoice_details, through: :invoice

  accepts_nested_attributes_for :delivery_note_details, reject_if: :all_blank, allow_destroy: true

  before_validation :set_number
  after_save :adjust_stocks, if: Proc.new{|dn| saved_change_to_state?}
  after_create :create_seles_file, if: Proc.new{|dn| dn.sales_file.nil? && !dn.invoice.nil?}

  STATES = ["Pendiente", "Anulado", "Finalizado"]

  validates_presence_of :company_id, message: "Debe pertenecer a una compañía."
  validates_presence_of :invoice_id, message: "Debe pertenecer a una factura."
  validates_presence_of :user_id, message: "El remito debe estar vinculado a un usuario."
  validates_presence_of :number, message: "No puede exitir un remito sin numeración."
  validates_presence_of :state, message: "El remito debe poseer un estado."
  validates_inclusion_of :state, in: STATES, message: "El estado es inválido."
  validates_uniqueness_of :number, scope: :company_id, message: "Ya existe un remito con ese número."

  default_scope { where(active: true) }
  after_initialize :set_default_number, if: :new_record?
  after_initialize :set_date, if: :new_record?


  #FILTROS DE BUSQUEDA
  	def self.without_system
  		where.not(generated_by: "system")
  	end

  	def self.search_by_invoice number
      if not number.blank?
        where("invoices.comp_number ILIKE ?", "%#{number}%")
      else
        all
      end
    end

    def self.search_by_user name
      if not name.blank?
        where("LOWER(users.first_name || ' ' || users.last_name) LIKE LOWER(?)", "%#{name}%")
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

  #ATRIBUTOS
  	def editable?
  		state == "Pendiente" || new_record?
  	end

    def invoice_comp_number
      invoice.nil? ? "" : invoice.comp_number
    end

    def client
      Client.unscoped{ super }
    end

    def delivery_note_details_attributes=(attributes)
      self.delivery_note_details.each do |dnd|
        dnd.mark_for_destruction
      end
      super
    end
  #ATRIBUTOS

  #PROCESOS
    def create_seles_file
      if sales_file_id.nil?
        if invoice_id.nil?
          sf = SalesFile.create(
            company_id: company_id,
            client_id: client_id,
            responsable_id: user_id
          )
          update_column(:sales_file_id, sf.id)
        else
          update_column(:sales_file_id, invoice.sales_file_id)
        end
      end
    end

    def adjust_stocks
      if self.state == "Anulado"
        self.delivery_note_details.each do |dnd|
          dnd.product.rollback_delivered_stock(quantity: dnd.quantity, depot_id: dnd.depot_id)
        end
        self.invoice.invoice_details.each do |id|
          id.reserve_stock
        end
      end
    end

    def set_default_number
      last_an = DeliveryNote.where(company_id: company_id).last
      self.number ||= last_an.nil? ? "00000001" : (last_an.number.to_i + 1).to_s.rjust(8,padstr= '0')
    end

    def set_date
      self.date ||= Date.today
    end

    def set_number
      self.number = self.number.to_s.rjust(8,padstr= '0')
    end

    def destroy
      update_column(:active, false)
      run_callbacks :destroy
      freeze
    end
  #PROCESOS


end
