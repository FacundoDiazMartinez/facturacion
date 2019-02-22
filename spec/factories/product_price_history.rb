FactoryBot.define do
  factory :product_price_history do
    association :product
    price {22}
    percentage {"Infinity"}
  end
end
