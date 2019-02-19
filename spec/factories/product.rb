FactoryBot.define do
  factory :product do
    association :product_category
    association :company
    association :created_by
  	sequence(:code) { |n| "#{n}CODE" }
  	active {true}
  	cost_price {}
    price {22}
    percentage {"Infinity"}
  end
end
