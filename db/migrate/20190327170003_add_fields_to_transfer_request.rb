class AddFieldsToTransferRequest < ActiveRecord::Migration[5.2]
  def change
    add_column :transfer_requests, :sended_by, :bigint
    add_column :transfer_requests, :received_by, :bigint
    add_column :transfer_requests, :sended_at, :datetime
    add_column :transfer_requests, :received_at, :datetime
  end
end
