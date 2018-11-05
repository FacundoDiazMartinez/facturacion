class CreateAccountMovements < ActiveRecord::Migration[5.2]
  def change
    create_table :account_movements do |t|
      t.references :client, foreign_key: true
      t.references :invoice, foreign_key: true
      t.references :receipt, foreign_key: true
      t.integer :days
      t.string :cbte_tipo, null: false
      t.boolean :debe
      t.boolean :haber
      t.float :total, null: false, default: 0.0
      t.float :saldo, null:false, default: 0.0

      t.timestamps
    end

    add_column :clients, :saldo, :float, null:false, default: 0.0
  end
end
