class ChangePaymentDayToBeString < ActiveRecord::Migration[5.2]
  def change
  	change_column :clients, :payment_day, :string
  end
end
