class AddGeneretedByToPayments < ActiveRecord::Migration[5.2]
  def change
    add_column :payments, :generated_by_system, :boolean, null: false, default: false
  end
end
