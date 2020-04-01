class PurchaseInvoice < ApplicationRecord
  belongs_to :company
  belongs_to :user
  belongs_to :supplier
  belongs_to :purchase_order, optional: true

  has_many   :iva_books, dependent: :destroy

  BILL_TYPES={
    "FA": "Factura A",
    "NCA": "Nota de Crédito A",
    "NDA": "Nota de Débito A",
    "FB": "Factura B",
    "NCB": "Nota de Crédito B",
    "NDB": "Nota de Débito B",
    "FC": "Factura C",
    "NCC": "Nota de Crédito C",
    "NDC": "Nota de Débito C"
  }

  after_create :create_iva_book

  default_scope{ where(active:true) }

  def purchase_order_number
    purchase_order.nil? ? "" : purchase_order.number
  end

  def tipo
    BILL_TYPES[cbte_tipo.to_sym]
  end

  def destroy
    update_column(:active, false)
    run_callbacks :destroy
    freeze
  end

  private

  def self.search_by_supplier name
    return all if name.blank?
    where("suppliers.name ILIKE ?", "%#{name}%")
  end

  def self.search_by_user name
    return all if name.blank?
    where("LOWER(users.first_name || ' ' || users.last_name) LIKE LOWER(?)", "%#{name}%")
  end

  def create_iva_book
    IvaBook.add_from_purchase(self)
  end
end
