class AddProductCodeToTransferRequestDetails < ActiveRecord::Migration[5.2]
  def change
    add_column :transfer_request_details, :product_code, :string
  end
end
