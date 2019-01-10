class DeliveryNote < ApplicationRecord
  belongs_to :company,optional: true
  belongs_to :invoice,optional: true
  belongs_to :user,optional: true
  belongs_to :client,optional: true

  has_many :delivery_note_details, dependent: :destroy

  validates_presence_of :company, message: "Debe especifica una compañía."
  validates_presence_of :invoice, message: "Debe especificar una factura asociada."
  validates_presence_of :user, 	  message: "Debe especificar un usuario."
  validates_presence_of :client,  message: "Debe especificar un cliente."

  accepts_nested_attributes_for :delivery_note_details, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :invoice, reject_if: :all_blank

  before_validation :set_number

  after_save :adjust_stock, if: Proc.new{|dn| saved_change_to_state?}

  STATES = ["Pendiente", "Anulado", "Finalizado"]

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
  #ATRIBUTOS

  #PROCESOS
    def set_number
      last_delivery_note = DeliveryNote.where(company_id: company_id).last
      self.number ||= last_delivery_note.nil? ? "00001" : (last_delivery_note.number.to_i + 1)
      self.number = self.number.to_s.rjust(5,padstr= '0')
    end

    def adjust_stock
      from = invoice.nil? ? "Disponible" : "Reservado" #Si el remito se crea de una factura, se disminuye el stock de los reservados, si no tiene factura asociada significa q nunca se reservo.
      self.delivery_note_details.each do |detail|
        case state
        when "Anulado"
          detail.product.deliver_product(quantity: -detail.quantity, depot_id: detail.depot_id, from: from)
        when "Finalizado"
          detail.product.deliver_product(quantity: detail.quantity, depot_id: detail.depot_id, from: from)
        end
      end
    end
  #PROCESOS

end
