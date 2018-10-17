class User < ApplicationRecord
	belongs_to :company, optional: true
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
end
