class AddConfirmadoToAccountMovement < ActiveRecord::Migration[5.2]
  def change
    add_column :account_movements, :confirmado, :boolean, null: false, default: false
  end
end
