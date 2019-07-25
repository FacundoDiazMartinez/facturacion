FactoryBot.define do
  factory :company do
    province
    locality
    email         { Faker::Internet.email }
    activity_init_date { Date.today }
    code          { "B01" }
    name          { Faker::Company.name }
    society_name  { name }
    cuit          { "20362340043" }
    concepto      { Company::CONCEPTOS.first }
    moneda        { "ARS" }
    iva_cond      { "Responsable Inscripto" }
    country       { "Argentina" }
    environment   { "testing" }
    paid          { false }
    logo          { Faker::Company.logo }
    postal_code   { "4400" }
    address       { Faker::Address.street_address }
  end
end
