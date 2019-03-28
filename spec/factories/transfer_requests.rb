FactoryBot.define do
  factory :transfer_request do
    company { nil }
    user { nil }
    transporter_id { "" }
    observation { "MyString" }
    date { "MyString" }
    from_depot_id { "" }
    to_depot_id { "" }
  end
end
