FactoryBot.define do
  factory :fee do
    credit_card { nil }
    quantity { 1 }
    coefficient { 1.5 }
    tna { 1.5 }
    tem { 1.5 }
    active { false }
  end
end
