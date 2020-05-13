class Budget < ApplicationRecord
  belongs_to :company
  belongs_to :user
  belongs_to :client

  has_one :invoice
  has_many :budget_details, dependent: :destroy
  has_many :products, through: :budget_details

  accepts_nested_attributes_for :budget_details, reject_if: :all_blank, allow_destroy: true

  STATES = ["Válido", "Confirmado", "Vencido", "Anulado", "Facturado"]

  before_validation :check_depots, :set_state, :set_number
  validate :expiration_date_cannot_be_in_the_past
  validates_inclusion_of :state, { in: STATES, message: "Estado inválido." }
  validates_presence_of :user_id, :number
  validates_uniqueness_of :number, scope: :company_id, message: "Número de presupuesto repetido. Intente guardar nuevamente el presupuesto."
  validates_presence_of :company_id, message: "El presupuesto debe estar asociado a una compañía."
  validates_presence_of :client_id, message: "El presupuesto debe estar asociado a un cliente."
  validates_presence_of :expiration_date, message: "Debe seleccionar una fecha de vencimiento."
  validates_presence_of :budget_details, message: "Debe ingresar al menos un detalle."
  after_validation :set_total

  after_save :schedule_expiration_date

  default_scope { where(active: true) }

  scope :pendientes,    -> { where(state: "Válido") }
  scope :confirmados,   -> { where(state: "Confirmado") }
  scope :expirados,     -> { where(state: "Vencido") }
  scope :anulados,      -> { where(state: "Anulado") }
  scope :facturados,    -> { where(state: "Facturado") }

  def self.search_by_number number
    return where("number ILIKE ?", "%#{number}%") unless number.blank?
    all
  end

  def self.search_by_state state
    return where("state = ?", state) unless state.blank?
    all
  end

  def self.search_by_client name
    return joins(:client).where("LOWER(clients.name) LIKE LOWER(?)", "%#{name}%") unless name.blank?
    all
  end

  def self.search_by_stock reservado
    return where("reserv_stock = ?", "#{reservado}") unless reservado.blank?
    all
  end

  def destroy
    update_column(:active, false) if editable?
	end

	def editable?
		valido? || vencido?
	end

  def valido?
    state == "Válido"
  end

  def confirmado?
    state == "Confirmado"
  end

  def facturado?
    state == "Facturado"
  end

  def vencido?
    state == "Vencido"
  end

  def anulado?
    state == "Anulado"
  end

  def valido!
    update_columns(state: "Válido")
  end

  def facturado!
    update_columns(state: "Facturado")
  end

  def vencido!
    update_columns(state: "Vencido")
  end

  def confirmado!
    update_columns(state: "Confirmado")
  end

  def anulado!
    update_columns(state: "Anulado")
  end

  def client
    Client.unscoped{ super }
  end

  def client_name
    client.nil? ? nil : client.name
  end

  private

  def schedule_expiration_date
    vencido! if self.expiration_date <= Date.today
  end
  handle_asynchronously :schedule_expiration_date, :run_at => Proc.new { |budget| budget.expiration_date + 1.days }

  def set_total
    self.total = budget_details.reject(&:marked_for_destruction?).pluck(:subtotal).inject(0, :+)
  end

  def set_state
    self.state = "Válido" if state.blank?
  end

  def check_depots
    if reserv_stock
      depositos_vacios = budget_details.reject(&:marked_for_destruction?).reject!{ |detail| !detail.depot_id.blank? }.nil?
      errors.add(:base, "Para reservar stock debe seleccionar DEPÓSITO en cada detalle.") if depositos_vacios
    end
  end

  def set_number
    if number.blank?
      ultimo_presupuesto = Budget.where(company_id: self.company_id).last
      return self.number = (ultimo_presupuesto.number.to_i + 1).to_s.rjust(8, '0') unless ultimo_presupuesto.nil?
      self.number = "00000001"
    end
  end

  def expiration_date_cannot_be_in_the_past
    errors.add(:expiration_date, "La fecha de vencimiento no puede ser menor a hoy.") if expiration_date && expiration_date < Date.today
  end
end
