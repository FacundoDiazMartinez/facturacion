require 'rails_helper'

RSpec.describe ArrivalNote, type: :model do
  subject {build_stubbed(:arrival_note)}
  it { should validate_presence_of(:company_id).with_message("Debe pertenecer a una compañía.") }
  it { should validate_presence_of(:purchase_order_id).with_message("Debe pertenecer a una orden de compra.") }
  it { should validate_presence_of(:user_id).with_message("El remito debe estar vinculado a un usuario.") }
  it { should validate_presence_of(:depot_id).with_message("El remito debe estar vinculado a un depósito.") }
  it { should validate_presence_of(:number).with_message("No puede exitir un remito sin numeración.") }
  it { should validate_presence_of(:state).with_message("El remito debe poseer un estado.") }
  it { should validate_inclusion_of(:state).in_array(ArrivalNote::STATES).with_message("El estado es inválido.") }
  it { should validate_uniqueness_of(:number).scoped_to([:company_id, :active]).with_message("Ya existe un remito con ese número.")}
end
