class Receipt < ApplicationRecord
  #RECIBO DE PAGO
  belongs_to :invoice

  has_one  :account_movement

  has_many :payments, through: :invoice

  after_save :touch_account_movement, if: Proc.new{|r| r.saved_change_to_total?}

  CBTE_TIPO = {
    "04"=>"Recibo A",
    "09"=>"Recibo B",
    "15"=>"Recibo C",
    "54"=>"Recibo M",
    "00"=>"Recibo X"
  }

  #PROCESOS
  	def touch_account_movement
  		am 				     = AccountMovement.where(receipt_id: id, cbte_tipo: "Recibo X").first_or_initialize
  		am.client_id 	 = invoice.client_id
  		am.receipt_id  = id
  		am.cbte_tipo	 = "Recibo X"
  		am.debe 		   = false
  		am.haber 		   = true
  		am.total 		   = total.to_f
  		am.saldo       = invoice.client.saldo.to_f - total.to_f unless !am.new_record?
  		am.save
  	end
  #PROCESOS
end
