require 'rails_helper'

RSpec.describe Product, type: :model do
  subject { create(:product, active: true)}
  it { should validate_presence_of(:code).with_message('Debe ingresar un código en el producto.') }
  it { should validate_uniqueness_of(:code).scoped_to([:company_id, :active, :tipo]).with_message('Ya existe un producto con el mismo identificador.') }
  it { should validate_presence_of(:name).with_message('El nombre del producto no puede estar en blanco.') }
  it { should validate_uniqueness_of(:name).scoped_to([:company_id, :active]).with_message('Ya existe un producto con el mismo nombre.') }
  it { should validate_presence_of(:price).with_message('Debe ingresar el precio del producto.') }
  it { should validate_numericality_of(:price).is_greater_than(0).with_message('El precio debe ser mayor a 0.') }
  it { should validate_presence_of(:cost_price).with_message('Debe ingresar el precio de costo del producto.') }
  it { should validate_presence_of(:created_by) }
  it { should validate_presence_of(:updated_by) }
  it { should validate_presence_of(:company_id) }
  it { should validate_presence_of(:code).with_message('Debe ingresar un código en el producto.') }
  it { should validate_presence_of(:iva_aliquot).with_message('Ingrese un valor para el IVA.') }
  it { should validate_inclusion_of(:measurement_unit).in_array(Product::MEASUREMENT_UNITS.keys) }
end
