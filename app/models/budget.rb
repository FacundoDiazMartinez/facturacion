class Budget < ApplicationRecord
  belongs_to :company
  belongs_to :user
  belongs_to :client

  has_many :budget_details, dependent: :destroy
  has_many :products, through: :budget_details

  accepts_nested_attributes_for :budget_details, reject_if: :all_blank, allow_destroy: true

  validate :expiration_date_cannot_be_in_the_past

  before_validation :set_number

  STATES = ["Pendiente", "Vencido", "Concretado"]

  #VALIDACIONES
    def expiration_date_cannot_be_in_the_past
      if expiration_date.present? && expiration_date < Date.today
        errors.add(:expiration_date, "La fecha de vencimiento no puede ser menor a hoy.")
      end
    end
  #VALIDACIONES

  #FILTROS DE BUSQUEDA
    def self.search_by_number number
      if not number.blank?
        where("number ILIKE ?", "%#{number}%")
      else
        all
      end
    end

    def self.search_by_user name
      if not name.blank?
        joins(:user).where("LOWER(users.first_name || ' ' || users.last_name) LIKE LOWER(?)", "%#{name}%")
      else
        all
      end
    end

    def self.search_by_client name
      if not name.blank?
        joins(:client).where("LOWER(clients.name) LIKE LOWER(?)", "%#{name}%")
      else
        all
      end
    end
  #FILTROS DE BUSQUEDA

  #PROCESOS
    def set_number
      last_budget = Budget.where(company_id: company_id).last
        self.number ||= last_budget.nil? ? "00001" : (last_budget.number.to_i + 1).to_s.rjust(5,padstr= '0')
    end
  #PROCESOS

  #ATRIBUTOS
  	def editable?
  		state != "Concretado"
  	end

    def client_name
      client.nil? ? nil : client.name
    end
  #ATRIBUTOS
end
