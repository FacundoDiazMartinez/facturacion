class SalePoint < ApplicationRecord
  belongs_to :company

  has_many :invoices

  before_validation :fill_name

  validates_numericality_of :name, message: "El punto de venta debe ser un número entero."

  #VALIDACIONES
	  def fill_name
	  	self.name = self.name.to_s.rjust(5,padstr= '0')
	  end
  #VALIDACIONES
end
