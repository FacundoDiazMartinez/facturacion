FactoryBot.define do
  factory :product_category do
    company
    supplier
    name { Faker::Commerce.product_name }
  end
end
