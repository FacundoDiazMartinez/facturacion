class CreateAuthorizedPersonal < ActiveRecord::Migration[5.2]
  def change
    create_table :authorized_personals do |t|
      t.string :first_name
      t.string :last_name
      t.string :dni
      t.boolean :need_purchase_order
      t.references :client, foreign_key: true

      t.timestamps
    end
  end
end
