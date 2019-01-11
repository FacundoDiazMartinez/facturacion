class DeliveryNote < ApplicationRecord

  belongs_to :company,optional: true
  belongs_to :invoice,optional: true
  belongs_to :user,optional: true
  belongs_to :client,optional: true
  belongs_to :sales_file, optional: true


  has_many :delivery_note_details, dependent: :destroy

  accepts_nested_attributes_for :delivery_note_details, reject_if: :all_blank, allow_destroy: true

  before_validation :set_number
  after_save :adjust_stock, if: Proc.new{|dn| saved_change_to_state?}
  after_create :create_seles_file, if: Proc.new{|dn| dn.sales_file.nil? && !dn.invoice.nil?}

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
