class Tribute < ApplicationRecord
  belongs_to :invoice

  before_save :set_description

  def sum_tributes
  	invoice.tributes.sum(:importe).to_f
  end

  def set_description
    self.desc = InvoiceManager::TaxesDescriptionSetter.call(self)
  end
end
