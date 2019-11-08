FactoryBot.define do
  factory :locality do
    name { "Salta" }
    association :province
  end
end
