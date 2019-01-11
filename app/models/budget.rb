class Budget < ApplicationRecord
  belongs_to :company, optional: true
  belongs_to :user, optional: true
  belongs_to :client, optional: true
  belongs_to :sales_file, optional: true

  has_many :budget_details, dependent: :destroy
  has_many :products, through: :budget_details

  accepts_nested_attributes_for :budget_details, reject_if: :all_blank, allow_destroy: true

  validate :expiration_date_cannot_be_in_the_past
  validates_presence_of :company_id, message: "El presupuesto debe estar asociado a una compañía."
  validates_presence_of :user_id, message: "El presupuesto debe estar asociado a un usuario."
  validates_presence_of :client_id, message: "El presupuesto debe estar asociado a un cliente."

  before_validation :set_number
  before_validation :check_depots, if: :reserv_stock

  after_create :create_seles_file, if: Proc.new{|b| b.sales_file.nil?}

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

    def check_depots
      errors.add(:base, "Si quiere reservar stock debe especificar el depósito en cada detalle.") unless !budget_details.map{|detail| detail.depot_id.blank?}.include?(true)
    end

    def create_seles_file
      sf = SalesFile.create(
        company_id: company_id,
        client_id: client_id,
        responsable_id: user_id
      )

      update_column(:sales_file_id, sf.id)
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
