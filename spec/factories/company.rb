FactoryBot.define do
  factory :company do
    association :province
    association :locality
    email {"litecode@sas.com"}
    code {"B01"}
    name {"Compañía 1"}
    cuit {"20362340043"}
    concepto {"Productos"}
    moneda {"ARS"}
    iva_cond {"Responsable Inscripto"}
    country {"Argentina"}
    environment {"testing"}
    paid {false}
  end
end