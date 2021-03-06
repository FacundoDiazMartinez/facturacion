class Advertisement < ApplicationRecord

  belongs_to :user,optional: true
  belongs_to :company,optional: true
  has_many :sended_advertisement, dependent: :destroy

  STATES = ["No enviado", "Enviado", "Anulado"]

  validates_presence_of :title, message: "Debe ingresar el título de la publicidad."
  validates_presence_of :active

  default_scope { where(active: true) }

  #FILTROS DE BUSQUEDA

    def self.search_by_user name
      if not name.blank?
        where("LOWER(users.first_name || ' ' || users.last_name) ILIKE LOWER(?)", "%#{name}%")
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

  #ATRIBUTOS
  def image1
    read_attribute("image1") || "/images/select_image.png"
  end

  def delivery_date
    dd = read_attribute("delivery_date")
    if not dd.blank?
      I18n.l(dd)
    else
      return dd
    end
  end
  #ATRIBUTOS

  #FUNCIONES
  def editable?
    state == "No enviado" || new_record?
  end
  #FUNCIONES

  #PROCESOS
  def destroy
    update_column(:active, false)
    run_callbacks :destroy
  end
  #PROCESOS


end
