class SalePoint < ApplicationRecord
  belongs_to :company

  before_validation :fill_name

  validates_numericality_of :name, message: "El punto de venta debe ser un número."

  #VALIDACIONES
	  def fill_name
	  	pp "ENTRO"
	  	self.name = self.name.to_s.rjust(5,padstr= '0')
	  end
  #VALIDACIONES
end
