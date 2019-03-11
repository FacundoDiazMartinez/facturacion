FactoryBot.define do
  factory :debit_payment do
    bank { nil }
    payment { nil }
    total { 1.5 }
    active { false }
  end
end
