FactoryBot.define do
  factory :product do
    association :product_category
    association :company
    association :created_by, factory: :user
    association :updated_by, factory: :user
  	sequence(:code) { |n| "CODE #{n}" }
    sequence(:supplier_code) { |n| "SUP_CODE #{n}" }
    sequence(:name) { |n| "Producto #{n}"}
  	active {true}
    net_price {100}
  	cost_price {100}
    price {121}
    tipo {"Producto"}
    iva_aliquot {"05"}
    percentage {"Infinity"}
  end
end
