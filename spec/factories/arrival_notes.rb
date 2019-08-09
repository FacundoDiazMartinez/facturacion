FactoryBot.define do
  factory :arrival_note do
    association :company
    association :purchase_order
    association :user
    association :depot
  end
end
