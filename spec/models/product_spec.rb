require 'rails_helper'

RSpec.describe Product, type: :model do
  context "when active" do
    subject { create(:product, active: true)}
    it { should validate_presence_of(:price).with_message('Debe ingresar el precio del producto.') }
    it { should validate_presence_of(:net_price).with_message('Debe ingresar el precio neto del producto.') }
    it { should validate_presence_of(:cost_price).with_message('Debe ingresar el precio de costo del producto.') }
    it { should validate_presence_of(:created_by).with_message('Debe ingresar el usuario creador del producto.') }
    it { should validate_presence_of(:updated_by).with_message('Debe ingresar quien actualizó el producto.') }
    it { should validate_presence_of(:code).with_message('Debe ingresar un código en el producto.').on(:create) }
    it { should validate_presence_of(:name).with_message('El nombre del producto no puede estar en blanco.').on(:create) }
    it { should validate_presence_of(:company_id).with_message('El producto debe estar asociado a su compañía.') }
    it { should validate_presence_of(:iva_aliquot).with_message('Ingrese un valor para el IVA.') }

    it { should validate_uniqueness_of(:code).scoped_to(:company_id,:active,:tipo).with_message('Ya existe un producto con el mismo identificador.').on(:create) }
    it { should validate_uniqueness_of(:supplier_code).with_message('Ya existe un producto con el mismo código de proveedor.') }
    it { should validate_uniqueness_of(:name).scoped_to(:company_id, :active).with_message('Ya existe un producto con el mismo nombre.').on(:create) }

    it { should validate_numericality_of(:price).with_message('El precio sólo debe contener caracteres numéricos') }
  end

  context 'when not active' do
    subject {create(:product, active: false)}
    it { should validate_presence_of(:updated_by).with_message('Debe ingresar quien actualizó el producto.') }
    it { should validate_presence_of(:code).with_message('Debe ingresar un código en el producto.').on(:create) }
    it { should validate_presence_of(:name).with_message('El nombre del producto no puede estar en blanco.').on(:create) }
    it { should validate_presence_of(:company_id).with_message('El producto debe estar asociado a su compañía.') }

    it { should validate_uniqueness_of(:code).scoped_to(:company_id, :active, :tipo).with_message('Ya existe un producto con el mismo identificador.').on(:create) }
    it { should validate_uniqueness_of(:supplier_code).scoped_to(:company_id, :active, :tipo).with_message('Ya existe un producto con el mismo código de proveedor.') }
    it { should validate_uniqueness_of(:name).scoped_to(:company_id, :active).with_message('Ya existe un producto con el mismo nombre.').on(:create) }
  end
end
