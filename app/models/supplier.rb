class Supplier < ApplicationRecord
  belongs_to :company
  belongs_to :creator, class_name: "User", foreign_key: 'created_by'
  belongs_to :updater, class_name: "User", foreign_key: 'updated_by'

  has_many 	 :purchase_orders
  has_many 	 :purchase_invoices
  has_many   :product_categories
  has_many   :products
  has_many   :price_changes

  validates_presence_of :name, message: "Debe ingresar el nombre del proveedor."
  validates_presence_of :document_type, message: "Tipo de documento inválido."
  validates_presence_of :document_number, message: "Documento requerido."
  validates_presence_of :titular, message: "Debe ingresar el nombre del titular o representante."
  validates_presence_of :company_id, :created_by, :updated_by

  default_scope { where(active: true ) }

	def full_document
	"#{Afip::DOCUMENTOS.key(document_type)}: #{document_number}"
	end

  def full_document
    "#{Afip::DOCUMENTOS.key(document_type)}: #{document_number}"
  end

  def destroy
		update_column(:active, false)
		run_callbacks :destroy
	end

  def self.search_by_name name
    if !name.nil?
      where("LOWER(name) LIKE LOWER(?)", "%#{name}%")
    else
      all
    end
  end

  def self.search_by_document document_number
    if !document_number.blank?
      where("document_number ILIKE ?", "#{document_number}%")
    else
      all
    end
  end
end
