require 'rails_helper'

RSpec.describe Depot, type: :model do
  subject { create(:depot) }
  it { should validate_presence_of(:name).with_message("El nombre no puede estar en blanco.") }
  it { should validate_presence_of(:filled).with_message("Debe especificar si el depósito se encuentra lleno.") }
  it { should validate_presence_of(:location).with_message("Debe especificar una ubicación para el depósito.") }
  it { should validate_presence_of(:company_id).with_message("El depósito debe estar vinculado a una compañía.") }
  it { should validate_presence_of(:stock_count).with_message("Debe estar vinculado a un stock actual.") }
  it { should validate_numericality_of(:stock_count).is_greater_than_or_equal_to(0).with_message("El stock actual debe ser mayor o igual a 0.")}
end
