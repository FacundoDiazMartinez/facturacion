class CreateDefaultTributes < ActiveRecord::Migration[5.2]
  def change
    create_table :default_tributes do |t|
      t.references :company, foreign_key: true
      t.integer :tribute_id, null: false
      t.float :default_aliquot, null: false

      t.timestamps
    end
  end
end
