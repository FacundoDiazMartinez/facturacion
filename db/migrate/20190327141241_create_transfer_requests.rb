class CreateTransferRequests < ActiveRecord::Migration[5.2]
  def change
    create_table :transfer_requests do |t|
      t.references :company, foreign_key: true
      t.references :user, foreign_key: true
      t.bigint :transporter_id, null: false
      t.string :number, null: false
      t.string :state, null: false, default: "Pendiente"
      t.string :observation
      t.date :date, null: false, default: ->{ "CURRENT_DATE" }
      t.bigint :from_depot_id, null: false
      t.bigint :to_depot_id, null: false
      t.boolean :active, null: false, default: true

      t.timestamps
    end
  end
end
