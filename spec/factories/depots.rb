FactoryBot.define do
  factory :depot do
    association :company
    name {"Deposito 1"}
    active {true}
    filled {false}
    location {"Salta"}
  end
end
