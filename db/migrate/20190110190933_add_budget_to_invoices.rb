class AddBudgetToInvoices < ActiveRecord::Migration[5.2]
  def change
    add_reference :invoices, :budget, foreign_key: true
  end
end
