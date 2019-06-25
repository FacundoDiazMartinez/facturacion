class ChangeConfirmadoToAccountMovement < ActiveRecord::Migration[5.2]
  def change
    remove_column :account_movements, :confirmado
    add_column    :account_movements, :tiempo_de_confirmacion, :datetime
  end
end
