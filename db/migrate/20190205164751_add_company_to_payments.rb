class AddCompanyToPayments < ActiveRecord::Migration[5.2]
  def change
    add_reference :payments, :company, foreign_key: true
    add_reference :payments, :user, foreign_key: true
  end
end
