class TransferRequest < ApplicationRecord
  belongs_to :company
  belongs_to :user
  belongs_to :sender, class_name: "Depot", foreign_key: :from_depot_id
  belongs_to :receiver, class_name: "Depot", foreign_key: :to_depot_id
  has_many :transfer_request_details

  STATES = ["Pendiente", "En tránsito", "Finalizado"]

  before_validation :set_number, if: :new_record?

  validates_presence_of :sender, message: "Debe especificar remito remitente"
  validates_presence_of :receiver, message: "Debe especificar remito destinatario"
  validates_presence_of :user_id, message: "Debe especificar quien registra el remito"
  validates_presence_of :transporter_id, message: "Debe especificar quien es el transportista del remito"
  validates_presence_of :company_id, message: "Debe especificar la compañía"
  validates_presence_of :date, message: "Debe especificar la fecha del remito"
  validates_presence_of :number, message: "Debe especificar el número del remito"
  validates_presence_of :transfer_request_details, message: "Debe ingresar al menos 1 producto a trasladar."
  validates_inclusion_of :state, in: STATES, message: "Debe especificar remito remitente"
  validate :diferentes_depositos

  accepts_nested_attributes_for :transfer_request_details, reject_if: :all_blank, allow_destroy: true

  default_scope { where(active: true ) }

  def editable?
    pendiente? || new_record?
  end

  def pendiente?
    state == "Pendiente"
  end

  def pendiente!
    update_columns(state: "Pendiente")
  end

  def confirmado?
    state == "Finalizado"
  end

  def confirmar!
    update_columns(state: "Finalizado")
  end

  def en_camino?
    state == "En tránsito"
  end

  def en_camino!
    update_columns(sended_at: Time.now, state: "En tránsito")
  end

  def receiver
    Depot.unscoped {super}
  end

  def sender
    Depot.unscoped {super}
  end

  def user
    User.unscoped {super}
  end

  private

  def set_number
    last_an = TransferRequest.where(company_id: company_id).last
    self.number ||= last_an.nil? ? "00000001" : (last_an.number.to_i + 1).to_s.rjust(8, '0')
  end

  def diferentes_depositos
    errors.add(:depots, "Los depósitos de [Origen] y [Destino] deben ser diferentes.") if sender == receiver
  end

  def self.search_by_number number
    return all if number.blank?
    where("number ILIKE ?", "%#{number}%")
  end

  def self.search_by_state state
    return all if state.blank?
    where(state: state)
  end

  def self.serach_by_transporter transporter
    return all if transporter.blank?
    joins(:user).where("LOWER(users.first_name ||' ' || users.last_name) LIKE LOWER(?)", "%#{transporter}%")
  end

  def self.search_by_receiver receiver
    return all if receiver.blank?
    where(to_depot_id: receiver)
  end

  def self.search_by_sender sender
    return all if sender.blank?
    where(from_depot_id: sender)
  end
end
