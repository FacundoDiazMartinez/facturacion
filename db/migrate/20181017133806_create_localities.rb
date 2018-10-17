class CreateLocalities < ActiveRecord::Migration[5.2]
  def change
    create_table :localities do |t|
      t.string :name
      t.integer :code
      t.references :province, foreign_key: true

      t.timestamps
    end

    add_reference :companies, :locality, null: false
  end
end
