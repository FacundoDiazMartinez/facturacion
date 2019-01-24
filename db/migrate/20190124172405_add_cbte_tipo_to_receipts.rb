class AddCbteTipoToReceipts < ActiveRecord::Migration[5.2]
  def change
  	add_column :receipts, :cbte_tipo, :string, defaul: "00", null: false
  end
end
