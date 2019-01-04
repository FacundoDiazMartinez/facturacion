class ChangeAssociatedDocumentoToDailyCashMovements < ActiveRecord::Migration[5.2]
  def change
  	change_column :daily_cash_movements, :associated_document, :string
  end
end
