class AddRealTotalLeftBooleanToReceiptDetail < ActiveRecord::Migration[5.2]
   	def change
		add_column 		:receipt_details, :total_payed_boolean, :boolean, default: false
		remove_column 	:receipt_details, :rtl_invoice
	end
end
