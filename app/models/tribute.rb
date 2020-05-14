class Tribute < ApplicationRecord
  belongs_to :invoice

  validates_uniqueness_of :afip_id, scope: :invoice_id, message: "Está intentando registrar tributos repetidos."
  validates_numericality_of :alic, greater_than: 0, message: "Las alícuotas de los tributos deben ser mayores a 0."
  before_save :set_description

  def sum_tributes
  	invoice.tributes.sum(:importe).to_f
  end

  def set_description
    self.desc = InvoiceManager::TaxesDescriptionSetter.call(self)
  end
end
