class CreateTributes < ActiveRecord::Migration[5.2]
  def change
    create_table :tributes do |t|
      t.references :invoice, foreign_key: true
      t.string :afip_id, null: false
      t.string :desc, null: false
      t.float :base_imp, null: false, default: 0.0
      t.float :alic, null: false, default: 0.0
      t.float :importe, null: false, default: 0.0

      t.timestamps
    end
  end
end
