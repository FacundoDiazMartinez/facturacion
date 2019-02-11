class SalesFile < ApplicationRecord
  belongs_to :company
  belongs_to :client
  belongs_to :responsable, class_name: "User", foreign_key: "responsable_id"

  has_many :invoices
  has_many :budgets
  has_many :delivery_notes

  before_validation :set_number

  STATES = ["Abierto", "Cerrado"]

  #FILTROS DE BUSQUEDA
  	def self.search_by_user name
  		if !name.nil?
        	joins(:responsable).where("LOWER(users.first_name ||' ' || users.last_name) LIKE LOWER(?)", "%#{name}%")
	    else
	        all
	    end
  	end

    def self.search_by_client client
      if !client.nil?
          joins(:client).where("LOWER(clients.name) LIKE LOWER(?)", "%#{client}%")
      else
          all
      end
    end

    def self.search_by_state state
      if !state.blank?
        where(state: state)
      else
        all
      end
    end

    def self.search_by_date date
      if date.blank?
        all
      else
        where(date: date)
      end
    end
  #FILTROS DE BUSQUEDA

  #PROCESOS
    def set_number
      last_sales_file = SalesFile.where(company_id: company_id).last
      self.number ||= last_sales_file.nil? ? "00000001" : (last_sales_file.number.to_i + 1).to_s.rjust(8,padstr= '0')
    end
  #PROCESOS
end
