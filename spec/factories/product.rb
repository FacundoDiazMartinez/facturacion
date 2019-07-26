FactoryBot.define do
  factory :product do
    association :product_category
    association :company
    association :user_who_creates, factory: :user
    association :user_who_updates, factory: :user
  	sequence(:code) { |n| "CODE #{n}" }
    sequence(:supplier_code) { |n| "SUP_CODE #{n}" }
    sequence(:name) { |n| "Producto #{n}" }
  	active { true }
    net_price { 100 }
  	cost_price { 100 }
    price { 121 }
    tipo { Faker::Commerce.product_name }
  end
end
