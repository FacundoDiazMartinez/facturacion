class RenameObservationFromReceiptsToConcept < ActiveRecord::Migration[5.2]
  def change
  	rename_column :receipts, :observation, :concept
  end
end
