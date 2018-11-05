class AccountMovement < ApplicationRecord
  belongs_to :client
  belongs_to :invoice, optional: true
  belongs_to :receipt, optional: true

  before_save :update_others_movements, if: Proc.new{|am|  !am.new_record?}
  after_save  :update_debt

  #FUNCIONES
  	def days
  		read_attribute("days") || (Date.today - created_at.to_date).to_i / 1.days 
  	end

  	def self.sum_total_from_invoices_per_client client_id
  		Client.find(client_id).invoices.select("invoices.total").sum(:total)
  	end

  	def self.sum_total_from_receipts_per_client client_id
  		Client.find(client_id).receipts.select("receipts.total").sum(:total)
  	end

  	def update_others_movements

  		debe_dif 	= debe ? (total - total_was) : 0.0
  		haber_dif	= haber ? (total - total_was) : 0.0
  		total_dif = debe_dif + haber_dif
  		pp next_movements = AccountMovement.where("created_at >= ? AND client_id = ?", created_at, client_id)
  		next_movements.each do |am|
  			total_saldo = am.saldo + total_dif
  			am.update_column(:saldo, total_saldo)
  		end
  		client.update_column(:saldo, client.saldo + total_dif)
  	end

  	def update_debt
  		pp saldo = AccountMovement.where(client_id: client_id).last.saldo
  		client.update_column(:saldo, saldo)
  	end
  #FUNCIONES
end
