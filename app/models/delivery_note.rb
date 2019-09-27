class DeliveryNote < ApplicationRecord
  include Deleteable
  belongs_to :company,optional: true
  belongs_to :invoice,optional: true
  belongs_to :user,optional: true
  belongs_to :client,optional: true
  belongs_to :sales_file, optional: true

  has_many :delivery_note_details, dependent: :destroy
  has_many :invoice_details, through: :invoice

  accepts_nested_attributes_for :delivery_note_details, reject_if: :all_blank, allow_destroy: true

  before_validation :set_number
  after_save :adjust_stocks_by_dn_cancelled, if: Proc.new{|dn| dn.state == "Anulado"}
  after_save :adjust_stocks_by_dn_finalized, if: Proc.new{|dn| dn.state == "Finalizado"}

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
  #ATRIBUTOS

  #PROCESOS
    def adjust_stocks_by_dn_cancelled
      self.delivery_note_details.each do |dnd|
        if self.invoice.state == "Confirmado"
          dnd.product.rollback_stock_from_delivered_to_reserved(quantity: dnd.quantity, depot_id: dnd.depot_id, delivery_note_id: self.id)
        elsif self.invoice.state == "Anulado"
          update_column(:state, "Anulado")
        elsif self.invoice.state == "Anulado parcialmente"
          total_cn_details = 0
          dnd.delivery_note.invoice.credit_notes.each do |cn|
            cn.invoice_details.each do |cn_detail|
              if cn_detail.product_id == dnd.product_id
                total_cn_details += cn_detail.quantity
              end
            end
          end
          dnd.product.rollback_stock_from_delivered_to_available(quantity: (dnd.quantity - total_cn_details), depot_id: dnd.depot_id, delivery_note_id: self.id)
        end
      end
    end

    def adjust_stocks_by_dn_finalized
      self.delivery_note_details.each do |dnd|
        dnd.adjust_product_stock
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
  	end
  #PROCESOS
end
