FactoryBot.define do
  factory :bank do
    association :company
    name {"Banco X"}
    account_number {"146/3"}
    cbu {"1212212121212112121221"}
    current_amount {"100"}
  end
end
