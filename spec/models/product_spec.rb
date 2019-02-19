require 'rails_helper'

RSpec.describe Product, type: :model do
  it { should validate_presence_of(:code) }
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:active) }
  it { should validate_presence_of(:company) }
  it { should validate_presence_of(:net_price) }
  it { should validate_presence_of(:price) }
  it { should validate_presence_of(:iva_aliquot) }
  it { should validate_presence_of(:created_by) }
  it { should validate_presence_of(:updated_by) }

  it { should validate_uniqueness_of(:code) }
end
