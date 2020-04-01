class PurchaseOrder < ApplicationRecord
  belongs_to :supplier, optional: true
  belongs_to :user, optional: true
  belongs_to :company, optional: true

  has_many :purchase_order_details
  has_many :arrival_notes
  has_many :arrival_note_details, through: :arrival_notes
  has_one :product

  accepts_nested_attributes_for :purchase_order_details, reject_if: :all_blank, allow_destroy: true

  STATES = ["Pendiente", "Anulado", "Finalizada"]

  validates_uniqueness_of :number, scope: [:company, :active], message: "Número de orden repetido. Por favor, vuelta a intentarlo."
  validates_presence_of :supplier_id, message: "Debe especificar un proveedor."
  validates_presence_of :company_id, :user_id
  validates_presence_of :purchase_order_details, message: "Debe ingresar al menos 1 producto."
  validates_inclusion_of :state, in: STATES

  before_create :set_number

  default_scope { where(active: true) }
  scope :confirmados, -> { where(state: "Finalizada") }

  def pendiente?
    state == "Pendiente"
  end

  def editable?
    pendiente?
  end

  def confirmado?
    state == "Finalizada"
  end

  def confirmado!
    update_columns(state: "Finalizada")
  end

  def anulado?
    state == "Anulado"
  end

  def anulado!
    update_columns(state: "Anulado")
  end

  def enviado?
    delivered
  end

  def enviado!
    update_columns(delivered: true)
  end

  def details
    purchase_order_details
  end

  def name
    "Nº: #{number} - De: #{supplier.name}"
  end

  def name_with_comp
    "#{nombre_comprobante}: #{number}"
  end

  def nombre_comprobante
    "Órden de Compra"
  end

  def full_number
    number
  end

  def type_of_model
    "purchase_order"
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
    else
      errors.add(:state, "No puede eliminar una órden de compra anulada o finalizada.")
      return false
    end
  end

    # def update purchase_order_params, send_mail = false, email = nil
    #   response = super(purchase_order_params)
    #   if send_mail == "true" && response
    #     PurchaseOrderMailer.send_mail(self, email, company).deliver
    #     update_column(:delivered, true)
    #   end
    #   return response
    # end
  #PROCESOS

  private

  def self.search_by_supplier name
    return all if name.blank?
    where("suppliers.name ILIKE ?", "%#{name}%")
  end

  def self.search_by_user name
    return all if name.blank?
    where("LOWER(users.first_name || ' ' || users.last_name) LIKE LOWER(?)", "%#{name}%")
  end

  def self.search_by_state state
    return all if state.blank?
    where(state: state)
  end
end
