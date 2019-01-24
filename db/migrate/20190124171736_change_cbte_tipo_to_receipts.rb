class ChangeCbteTipoToReceipts < ActiveRecord::Migration[5.2]
  def change
  	remove_column :receipts, :cbte_tipo, :string
  	
  end
end
