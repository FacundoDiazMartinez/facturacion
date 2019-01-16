class PurchaseOrder < ApplicationRecord
  belongs_to :supplier, optional: true
  belongs_to :user, optional: true
  belongs_to :company, optional: true

  has_many :expense_payments
  has_many :purchase_order_details
  has_many :arrival_notes

  has_one :product

  default_scope { where(active: true) }

  accepts_nested_attributes_for :expense_payments, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :purchase_order_details, reject_if: :all_blank, allow_destroy: true

  before_create :set_number
  after_save :set_sended_activity, if: Proc.new{|po| po.saved_change_to_state? && po.state == "Enviado"}
  after_save :set_activity, if: Proc.new{|po| po.saved_change_to_state? && po.state != "Enviado"}
  after_save :touch_payments
  after_touch :set_paid_out

  validates_uniqueness_of :number, scope: :company_id, message: "Error intero del servidor, intentelo nuevamente por favor."
  validates_presence_of :supplier_id, message: "Debe especificar un proveedor."
  validates_presence_of :user_id, message: "Debe especificar un usuario."
  validates_presence_of :company_id, message: "Debe especificar una compañía."

  before_validation :check_pending_arrival_notes, if: Proc.new{|po| po.state_changed? && po.state == "Finalizada"}

  STATES = ["Pendiente de aprobación", "Aprobado", "Anulado", "Finalizada"]

  #ATRIBUTOS
  	def total_left
  		(total - total_pay).round(2)
  	end

  	def supplier_email
  		supplier.nil? ? "-" : supplier.email
  	end

  	def supplier_phone
  		supplier.nil? ? "-" : supplier.phone
  	end

    def details
      purchase_order_details
    end

    def name
      "Nº: #{number} - De: #{supplier.name}"
    end

    def name_with_comp
      "Orden de compra: #{number}"
    end

    def created_at
      if not super.blank?
  			I18n.l(super.to_date)
  		end
    end

    def pending_approval?
      state == STATES[0]
    end

    def editable?
      state != "Anulado" && state != "Finalizada"
    end
  #ATRIBUTOS

  #FILTROS DE BUSQUEDA
    def self.search_by_supplier name
      if not name.blank?
        where("suppliers.name ILIKE ?", "%#{name}%")
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

  #PROCESOS
    def check_pending_arrival_notes
      self.arrival_notes.each do |an|
        if an.editable?
          errors.add(:state, "No se pudo cerrar Orden de Compra. Existen remitos asociados pendientes.")
          self.state = state_was
          break
        end
      end
    end

    def set_number
      last_po = PurchaseOrder.where(company_id: company_id).last
      self.number = last_po.nil? ? "00000001" : (last_po.number.to_i + 1).to_s.rjust(8,padstr= '0')
    end

    def set_sended_activity
      UserActivity.create_for_sended_purchase_order self
    end

    def set_activity
      UserActivity.create_for_purchase_order self
    end

    def destroy
      if self.editable?
        update_column(:active, false)
        run_callbacks :destroy
        freeze
      end
    end

    def touch_payments
      expense_payments.map{|p| p.run_callbacks(:save)}
    end

    # def close_arrival_notes
    #   self.arrival_notes.each do |an|
    #     an.update_column(:state, "Finalizado") unless an.state == "Anulado"
    #   end
    # end

    def set_paid_out
      set_total_pay
      if total.to_f - total_pay == 0
        update_column(:paid_out, true)
      end
    end

    def set_total_pay
      update_column(:total_pay, sum_payments)
    end
  #PROCESOS

  #FUNCIONES
    def self.approved_orders
      where(state: "Aprobado").map{|po| [po.number, po.id]}
    end

    def sum_details
      self.purchase_order_details.sum(:total)
    end

    def sum_payments
      self.expense_payments.sum(:total)
    end

    def array_of_state_values
      if editable?
        STATES.reject{|x| x == "Anulado"}
      else
        STATES
      end
    end
  #FUNCIONES
end
