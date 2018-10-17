class CreateProvinces < ActiveRecord::Migration[5.2]
  def change
    create_table :provinces do |t|
      t.string :name
      t.integer :code
      t.timestamps
    end

    add_reference :companies, :province, null: false
  end
end
