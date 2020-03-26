class DeliveryNote < ApplicationRecord
  include Deleteable
  belongs_to :company
  belongs_to :invoice
  belongs_to :user
  belongs_to :client, optional: true

  has_many :delivery_note_details, dependent: :destroy
  has_many :invoice_details, through: :invoice

  accepts_nested_attributes_for :delivery_note_details, reject_if: :all_blank, allow_destroy: true

  before_validation :set_number, if: :new_record?

  STATES = ["Pendiente", "Anulado", "Finalizado"]

  validates_presence_of :invoice_id, message: "Debe pertenecer a una factura."
  validates_presence_of :user_id, :number, :state
  validates_inclusion_of :state, in: STATES, message: "Estado inválido."
  validates_uniqueness_of :number, scope: [:company, :active], message: "Ya existe un remito con ese número."
  validates_presence_of :delivery_note_details, message: "Debe ingresar al menos 1 concepto en el remito."

  default_scope { where(active: true) }
  scope :pendientes,  -> { where(state: "Pendiente") }
  scope :anulados,    -> { where(state: "Anulado") }
  scope :finalizados, -> { where(state: "Finalizado") }
  scope :without_system, -> { where.not(generated_by: "system") }

	def self.search_by_invoice number
    return all if number.blank?
    where("invoices.comp_number ILIKE ?", "%#{number}%")
  end

  def self.search_by_user name
    return all if name.blank?
    where("LOWER(users.first_name || ' ' || users.last_name) LIKE LOWER(?)", "%#{name}%")
  end

  def self.search_by_state state
    return all if state.blank?
    where(state: state)
  end

	def editable?
		pendiente? || new_record?
	end

  def pendiente?
    state == "Pendiente"
  end

  def finalizado?
    state == "Finalizado"
  end

  def confirmar!
    update_columns(state: "Finalizado")
  end

  def anulado?
    state == "Anulado"
  end

  def anular!
    update_columns(state: "Anulado")
  end

  def invoice_comp_number
    invoice.nil? ? "" : invoice.comp_number
  end

  def client
    Client.unscoped{ super }
  end

  def destroy
		update_column(:active, false)
		run_callbacks :destroy
	end

  private

  def set_number
    last_an = DeliveryNote.where(company_id: company_id).last
    self.number ||= last_an.nil? ? "00000001" : (last_an.number.to_i + 1).to_s.rjust(8,padstr= '0')
  end
end
