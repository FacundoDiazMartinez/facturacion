class User < ApplicationRecord
	belongs_to :company, optional: true
	belongs_to :province, optional: true
	belongs_to :locality, optional: true

  has_many :arrival_notes
  has_many :purchase_invoices
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable


  	def set_company company_id
  		update_attribute(:company_id, company_id)
  	end

  	def has_company?
  		not company_id.nil?
  	end

    def name
      "#{last_name}, #{first_name}"
    end

		def birthday
			if not super.blank?
				I18n.l(super)
			end
	  end
end
