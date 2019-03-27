FactoryBot.define do
  factory :compensation_payment do
    total { "" }
    payment { "" }
    active { "" }
    asociatedClientInvoice { "" }
    observation { "" }
    concept { "" }
    client { nil }
  end
end
