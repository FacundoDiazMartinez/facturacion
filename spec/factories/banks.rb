FactoryBot.define do
  factory :bank do
    association :company
    name {"Banco X"}
    cbu {"1212212121212112121221"}
    account_number {"146/3"}
    current_amount {"100"}
  end
end
