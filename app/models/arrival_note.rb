class ArrivalNote < ApplicationRecord
  belongs_to :company
  belongs_to :user
  belongs_to :depot
  belongs_to :purchase_order, optional: true
  has_many :arrival_note_details, dependent: :destroy
  has_many :purchase_order_details, through: :purchase_order

  accepts_nested_attributes_for :arrival_note_details, reject_if: :all_blank , allow_destroy: true

  before_validation :set_number, if: :new_record?

  STATES = ["Pendiente", "Finalizado"]

  validates_presence_of :company_id, message: "Debe pertenecer a una compañía."
  validates_presence_of :purchase_order_id, message: "Debe pertenecer a una orden de compra."
  validates_presence_of :depot_id, message: "Debe especificar un depósito destino."
  validates_presence_of :state
  validates_inclusion_of :state, in: STATES, message: "El estado es inválido."
  validates_presence_of :number
  validates_uniqueness_of :number, scope: [:company, :active], message: "Ya existe un remito con ese número."

  default_scope { where(active: true) }
  scope :confirmados, -> { where(state: "Finalizado") }

  def destroy
    if self.confirmado?
      errors.add(:state, "No puede eliminar un remito finalizado.")
      return false
    else
      update_column(:active, false)
      run_callbacks :destroy
      freeze
    end
  end

  def editable?
    pendiente?
  end

  def pendiente?
    state == "Pendiente"
  end

  def confirmado?
    state == "Finalizado"
  end

  def confirmado!
    update_columns(state: "Finalizado")
  end

  def depot
    Depot.unscoped{super}
  end

  private

  def self.search_by_purchase_order number
    return all if number.blank?
    where("purchase_orders.number ILIKE ?", "%#{number}%")
  end

  def self.search_by_user name
    return all if name.blank?
    where("LOWER(users.first_name || ' ' || users.last_name) LIKE LOWER(?)", "%#{name}%")
 end

  def self.search_by_state state
    return all if state.blank?
    where(state: state)
  end

  def set_number
    last_an = ArrivalNote.where(company_id: company_id).last
    self.number ||= last_an.nil? ? "00000001" : (last_an.number.to_i + 1).to_s.rjust(8,padstr= '0')
  end
end
