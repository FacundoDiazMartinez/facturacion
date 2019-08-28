class Bonification < ApplicationRecord
  belongs_to :invoice

  validates :percentage,
            presence: { message: "Debe ingresar la alícuota del descuento." },
            numericality: { greater_than: 0, less_than: 50, message: "La alícuota de descuento debe ser mayor a 0." }
end
