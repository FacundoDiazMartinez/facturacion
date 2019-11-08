FactoryBot.define do
  factory :depot do
    association :company, factory: :company
    sequence(:name) { |n| "DepositoN#{n}"}
    active { true }
    filled { false }
    location {"Salta"}
    stock_count {22}
  end
end
