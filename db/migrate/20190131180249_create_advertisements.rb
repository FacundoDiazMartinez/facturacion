class CreateAdvertisements < ActiveRecord::Migration[5.2]
  def change
    create_table :advertisements do |t|
      t.string :title, null: false
      t.text :body
      t.string :image1
      t.date :delivery_date, null: false
      t.boolean :active, default: true, null: false
      t.string :state, default: "No enviado", null: false

      t.timestamps
    end
    add_reference :advertisements, :user, foreign_key: true
    add_reference :advertisements, :company, foreign_key: true
  end
end
