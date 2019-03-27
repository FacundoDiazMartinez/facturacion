FactoryBot.define do
  factory :transfer_request_detail do
    transfer_request { nil }
    product { nil }
    quantity { 1.5 }
    observation { "MyText" }
  end
end
