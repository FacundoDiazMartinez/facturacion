require 'rails_helper'

RSpec.describe Tribute, type: :model do
  subject { create(:tribute) }
  it { should validate_presence_of(:invoice_id).with_message("Comprobante no seleccionado.") }
  it { should validate_presence_of(:afip_id) }
  it { should validate_presence_of(:desc) }
  it { should validate_presence_of(:alic).with_message("Alícuota no seleccionada.") }
end
