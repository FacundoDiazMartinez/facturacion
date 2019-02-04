class Advertisement < ApplicationRecord
  
  belongs_to :user,optional: true
  belongs_to :company,optional: true

  STATES = ["No enviado", "Enviado", "Anulado"]

  validates_presence_of :title, message: "Debe ingresar el título de la publicidad."
  validates_presence_of :active
  validates_presence_of :delivery_date, message: "Debe ingresar fecha de envío."

  default_scope { where(active: true) }

  #FILTROS DE BUSQUEDA

    def self.search_by_user name
      if not name.blank?
        where("LOWER(users.first_name || ' ' || users.last_name) LIKE LOWER(?)", "%#{name}%")
      else
        all
      end
   end

    def self.search_by_state state
      if not state.blank?
        where(state: state)
      else
        all
      end
    end
  #FILTROS DE BUSQUEDA


end
