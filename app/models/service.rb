class Service < Product
  before_validation :set_tipo
	self.table_name =  "products"

  def self.default_scope
    where(active: true, tipo: "Servicio")
  end

  def set_tipo
    self.tipo = "Servicio"
  end

end
