class AddModificatorToSupplier < ActiveRecord::Migration[5.2]
  def change
    add_column :suppliers, :created_by, :bigint, foreign_key: true
    add_column :suppliers, :updated_by, :bigint, foreign_key: true
  end
end
