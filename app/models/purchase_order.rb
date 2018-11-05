class PurchaseOrder < ApplicationRecord
  belongs_to :supplier
  belongs_to :user
  belongs_to :company

  has_many :payments
  has_many :purchase_order_details

  accepts_nested_attributes_for :payments, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :purchase_order_details, reject_if: :all_blank, allow_destroy: true

  #ATRIBUTOS
  	def total_left
  		(total - total_pay).round(2)
  	end

  	def supplier_email
  		supplier.nil? ? "-" : supplier.email
  	end

  	def supplier_phone
  		supplier.nil? ? "-" : supplier.phone
  	end

    def details
      purchase_order_details
    end
  #ATRIBUTOS
end
