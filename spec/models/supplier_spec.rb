require 'rails_helper'

RSpec.describe Supplier, type: :model do
  subject { create(:supplier) }
  it { should validate_presence_of(:name).with_message("Debe ingresar el nombre del proveedor.") }
  it { should validate_presence_of(:document_type).with_message("Tipo de documento inválido.") }
  it { should validate_presence_of(:document_number).with_message("Documento requerido.") }
  it { should validate_presence_of(:company_id) }
  it { should validate_presence_of(:created_by) }
  it { should validate_presence_of(:updated_by) }
  it { should validate_presence_of(:titular).with_message("Debe ingresar el nombre del titular o representante.") }
end
