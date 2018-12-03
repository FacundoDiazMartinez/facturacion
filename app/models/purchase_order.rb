class PurchaseOrder < ApplicationRecord
  belongs_to :supplier
  belongs_to :user
  belongs_to :company

  has_many :payments
  has_many :purchase_order_details

  has_one :product

  accepts_nested_attributes_for :payments, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :purchase_order_details, reject_if: :all_blank, allow_destroy: true

  before_create :set_number
  after_save :set_sended_activity, if: Proc.new{|po| po.saved_change_to_state? && po.state == "Enviado"}
  after_save :set_activity, if: Proc.new{|po| po.saved_change_to_state? && po.state != "Enviado"}



  validates_uniqueness_of :number, scope: :company_id, message: "Error intero del servidor, intentelo nuevamente por favor."

  STATES = ["Pendiente de aprobación", "Aprobado", "Enviado", "Anulado", "Finalizado"]

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

    def created_at
      if not super.blank?
  			I18n.l(super.to_date)
  		end
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
    def set_number
      last_po = PurchaseOrder.where(company_id: company_id).last
      self.number = last_po.nil? ? 1 : (last_po.number.to_i + 1)
    end

    def set_sended_activity
      UserActivity.create_for_sended_purchase_order self
    end

    def set_activity
      UserActivity.create_for_purchase_order self
    end
  #PROCESOS

  #FUNCIONES
    def self.sended_orders
      where(state: "Enviado").map{|s| [s.name, s.id]}
    end

    def sum_details
      self.purchase_order_details.sum(:total)
    end

  #FUNCIONES
end
