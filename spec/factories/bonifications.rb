FactoryBot.define do
  factory :bonification do
    subtotal { 1.5 }
    observation { "MyString" }
    percentage { 1.5 }
    amount { 1.5 }
    invoice { nil }
  end
end
