class TransferRequest < ApplicationRecord
  belongs_to :company
  belongs_to :user
  belongs_to :sender, class_name: "Depot", foreign_key: :from_depot_id
  belongs_to :receiver, class_name: "Depot", foreign_key: :to_depot_id
  has_many :transfer_request_details

  STATES = ["Pendiente", "Enviado", "Recibido", "Finalizado", "Anulado"]

  validates_presence_of :from_depot_id, message: "Debe especificar remito remitente"
  validates_presence_of :to_depot_id, message: "Debe especificar remito destinatario"
  validates_presence_of :user_id, message: "Debe especificar quien registra el remito"
  validates_presence_of :transporter_id, message: "Debe especificar quien es el transportista del remito"
  validates_presence_of :company_id, message: "Debe especificar la compañía"
  validates_presence_of :date, message: "Debe especificar la fecha del remito"
  validates_presence_of :number, message: "Debe especificar el número del remito"
  validates_inclusion_of :state, in: STATES, message: "Debe especificar remito remitente"
  validates_associated :transfer_request_details

  accepts_nested_attributes_for :transfer_request_details, reject_if: :all_blank, allow_destroy: true

  default_scope { where(active: true ) }

  before_save :check_state

  def self.search_by_number number
    if !number.blank?
      where("number ILIKE ?", "%#{number}%")
    else
      all
    end
  end
  def self.search_by_state state
    if !state.blank?
      where(state: state)
    else
      all
    end
  end
  def self.serach_by_transporter transporter
    if !transporter.blank?
      joins(:user).where("LOWER(users.first_name ||' ' || users.last_name) LIKE LOWER(?)", "%#{transporter}%")
    else
      all
    end
  end
  def self.search_by_receiver receiver
    if !receiver.blank?
      where(to_depot_id: receiver)
    else
      all
    end
  end
  def self.search_by_sender sender
    if !sender.blank?
      where(from_depot_id: sender)
    else
      all
    end
  end

  def editable?
    ["Pendiente"].include?(state)
  end

  def check_state
    if errors.any?
      self.state = state_was
    end
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

  def destroy
  	update_column(:active, false)
  	run_callbacks :destroy
  end

end
