class DeliveryNote < ApplicationRecord
  belongs_to :company
  belongs_to :invoice
  belongs_to :user
  belongs_to :client
  has_many :delivery_note_details, dependent: :destroy

  accepts_nested_attributes_for :delivery_note_details, reject_if: :all_blank, allow_destroy: true

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
      self.number = self.number.to_s.rjust(8,padstr= '0')
    end

    def destroy
      update_column(:active, false)
      run_callbacks :destroy
      freeze
    end
  #PROCESOS


end
