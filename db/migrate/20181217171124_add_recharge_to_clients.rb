class AddRechargeToClients < ActiveRecord::Migration[5.2]
  def change
    add_column :clients, :valid_for_account, :boolean, null: false, default: true
  end
end
