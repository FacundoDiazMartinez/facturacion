FactoryBot.define do
  factory :stock do
    association :depot
    association :product
    state {"Disponible"}
    quantity {1.0}
  end
end