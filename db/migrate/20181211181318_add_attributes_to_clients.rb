class AddAttributesToClients < ActiveRecord::Migration[5.2]
  def change
    add_column :clients, :recharge, :float
    add_column :clients, :payment_day, :integer
    add_column :clients, :observation, :string
  end
end
