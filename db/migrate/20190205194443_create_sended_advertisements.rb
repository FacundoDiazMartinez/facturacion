class CreateSendedAdvertisements < ActiveRecord::Migration[5.2]
  def change
    create_table :sended_advertisements do |t|
      t.references :advertisement, foreign_key: true
      t.text :clients_data, null: false

      t.timestamps
    end
  end
end
