require 'rails_helper'

RSpec.describe Bank, type: :model do
  subject { create(:bank) }
  it { should validate_presence_of(:name).with_message("El nombre no puede estar en blanco.") }
  it { should validate_presence_of(:account_number).with_message("El número de cuenta no puede estar en blanco.") }
  it { should validate_presence_of(:cbu).with_message("El CBU no puede estar en blanco.") }
  it { should validate_length_of(:cbu).is_equal_to(22).with_message("C.B.U. inválido. Verifique por favor. Cantidad necesaria de caracteres = 22.") }
  it { should validate_presence_of(:current_amount).with_message("Ingrese el monto inicial que quiere asignar al nuevo banco.") }
  it { should validate_numericality_of(:current_amount).is_greater_than(0).with_message("El monto inicial debe ser mayor o igual a 0.")}
end
