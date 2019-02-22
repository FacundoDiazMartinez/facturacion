FactoryBot.define do
  factory :product do
    association :product_category
    association :company
    association :created_by, factory: :user
    association :updated_by, factory: :user
  	sequence(:code) { |n| "#{n}CODE" }
  	active {true}
  	cost_price {220}
    price {22}
    percentage {"Infinity"}
  end
end
