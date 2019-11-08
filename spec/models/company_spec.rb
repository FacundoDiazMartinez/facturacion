require 'rails_helper'

RSpec.describe Company, type: :model do
  context "when is valid" do
    subject { create(:company) }
    it { should validate_presence_of(:name).with_message("Debe ingresar el nombre de su compañía.") }
    it { should validate_presence_of(:code).with_message("Error al generar el código de su compañía. Intentelo nuevamente por favor.") }
    it { should validate_presence_of(:society_name).with_message("Debe ingresar su razón social.") }
    it { should validate_presence_of(:moneda).with_message("Debe seleccionar su moneda principal.") }
    it { should validate_presence_of(:activity_init_date).with_message("Debe indicar la fecha de inicio de actividad de su compañía.") }
    it { should validate_presence_of(:country).with_message("Debe seleccionar el país.") }
    it { should validate_presence_of(:province_id).with_message("Debe seleccionar una provincia.") }
    it { should validate_presence_of(:locality_id).with_message("Debe seleccionar una localidad.") }
    it { should validate_presence_of(:postal_code).with_message("Debe ingresar el código postal de la localidad.") }
    it { should validate_presence_of(:address).with_message("Debe ingresar la dirección de su compañía.") }
    it { should validate_presence_of(:cuit).with_message("El C.U.I.T. no puede estar en blanco.") }
    it { should validate_numericality_of(:cuit).is_greater_than(9999999999).is_less_than(99999999999).with_message("El C.U.I.T. debe contener únicamente números.") }
    it { should validate_presence_of(:concepto).with_message("Debe seleccionar un concepto.") }
    it { should validate_inclusion_of(:concepto).in_array(["01","02","03"]).with_message("El concepto seleccionado es inválido.") }
    it { should validate_presence_of(:email).with_message("Debe ingresar una dirección de correo electrónico.") }
    it { should allow_value(Faker::Internet.email).for(:email) }
    it { should validate_length_of(:cbu).is_equal_to(22).allow_nil.with_message("C.B.U. inválido. Verifique por favor. Cantidad necesaria de caracteres = 22.") }
  end

  context "when is invalid" do
    it "validate the activity init date for being in the past" do
      company = FactoryBot.build(:company, activity_init_date: Date.tomorrow)
      company.valid?
      expect(company).to_not be_valid
    end
  end
end
