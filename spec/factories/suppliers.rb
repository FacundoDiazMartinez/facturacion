FactoryBot.define do
  factory :supplier do
    association :company
    association :creator, factory: :user
    association :updater, factory: :user
    name              { "RG Frenos" }
    document_type     { "CUIT" }
    document_number   { "20363580021" }
    phone             { "4121212" }
    mobile_phone      { "154121212" }
    address           { "Pje Klein 23" }
    email             { "rgfrenos@admin.com" }
    cbu               { "1212122112121212122121" }
    active            { true }
    titular           { "Jose Manrique" }
    bank_name         { "MACRO" }
    iva_cond          { "Responsable Inscripto" }
  end
end
