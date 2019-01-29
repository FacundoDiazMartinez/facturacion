class AddStateToReceipt < ActiveRecord::Migration[5.2]
  def change
    add_column :receipts, :state, :string, default: "Pendiente"
  end
end
