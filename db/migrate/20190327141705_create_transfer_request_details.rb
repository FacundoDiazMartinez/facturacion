class CreateTransferRequestDetails < ActiveRecord::Migration[5.2]
  def change
    create_table :transfer_request_details do |t|
      t.references :transfer_request, foreign_key: true
      t.references :product, foreign_key: true
      t.float :quantity, null: false, defaul: 0
      t.boolean :active, null: false, default: true
      t.text :observation

      t.timestamps
    end
  end
end
