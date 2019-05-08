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
  validates_presence_of :expiration_date, message: "Debe seleccionar una fecha de vencimiento."

  # before_validation :set_number
  after_initialize :set_number, if: :new_record?
  before_validation :check_depots, if: :reserv_stock
  before_validation :set_total_to_budget
  after_save :change_state_to_expirated
  after_create :create_seles_file, if: Proc.new{|b| b.sales_file.nil?}

  STATES = ["Generado", "Válido", "Vencido", "Concretado"]

  default_scope { where(active: true ) }


  #VALIDACIONES
    def expiration_date_cannot_be_in_the_past
      if expiration_date.present? && expiration_date < Date.today
        errors.add(:expiration_date, "La fecha de vencimiento no puede ser menor a hoy.")
      end
    end

    # def expiration_date_cannot_be_in_the_past
    #   if expiration_date.present?
    #     if expiration_date < Date.today
    #       errors.add(:expiration_date, "La fecha de vencimiento no puede ser menor a hoy.")
    #     end
    #   else
    #     errors.add(:expiration_date, "Debe seleccionar una fecha de vencimiento.")
    #   end
    # end
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
      self.number ||= last_budget.nil? ? "00000001" : (last_budget.number.to_i + 1).to_s.rjust(8,padstr= '0')
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

    def set_total_to_budget
      suma = Float(0)
      budget_details.each do |b|
        suma = suma + b.subtotal.to_f
      end
      self.total = suma
    end

    def change_state_to_expirated
      if self.expiration_date <= Date.today
        self.state = "Vencido"
      end
    end
    handle_asynchronously :change_state_to_expirated, :run_at => Proc.new { |budget| budget.expiration_date + 1.days }

    def destroy
  		update_column(:active, false)
  		run_callbacks :destroy
  	end
  #PROCESOS

  #ATRIBUTOS
  	def editable?
  		!persisted?
  	end

    def client
      Client.unscoped{ super }
    end

    def client_name
      client.nil? ? nil : client.name
    end
  #ATRIBUTOS
end
