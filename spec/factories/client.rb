FactoryBot.define do
  factory :client do
    association :company
    association :user
    name {"Usuario x"}
    address {"Calle x"}
    document_type {"D.N.I"}
    document_number {"36234004"}
    active {true}
    company_id {1}
    user_id {1}
    valid_for_account {true}
  end
end