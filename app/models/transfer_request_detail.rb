class TransferRequestDetail < ApplicationRecord
  belongs_to :transfer_request
  belongs_to :product

  validates_presence_of :product_code, message: "Debe ingresar el código del producto"
  validates_presence_of :quantity, message: "Especifique la cantidad a entregar"
  validates_numericality_of :quantity, greater_than: 0, message: "Cantidad incorrecta"
  
end
