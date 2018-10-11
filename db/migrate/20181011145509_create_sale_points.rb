class CreateSalePoints < ActiveRecord::Migration[5.2]
  def change
    create_table :sale_points do |t|
      t.references :company, foreign_key: true
      t.string :name

      t.timestamps
    end
  end
end
