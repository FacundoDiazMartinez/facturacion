class DeliveryNoteDetail < ApplicationRecord
  include Deleteable
  belongs_to :delivery_note, optional: true
  belongs_to :product, optional: true, class_name: "ProductUnscoped"
  belongs_to :depot
  belongs_to :invoice_detail, optional: true
  has_many :invoice_details, through: :delivery_note


  validates_presence_of :delivery_note, message:  "El concepto debe tener asociado un remito."
  validates_presence_of :product, message:  "El concepto debe tener asociado un producto."
  validates_presence_of :depot, message:  "El concepto debe tener asociado un depósito."

  validate :depot_has_stock?

  #after_validation :adjust_product_stock, if: Proc.new{|detail| detail.delivery_note.state == "Finalizado"}

  default_scope { where(active: true ) }

  #ATRIBUTOS
  	def product_name
  		product.nil? ? "" : product.name
  	end

  	def product_code
  		product.nil? ? "" : product.code
  	end

    def product
      Product.unscoped{super}
    end

    def _destroy
      @_destroy
    end

    def _destroy=(val)
      @_destroy = val
    end
  #ATRIBUTOS

  def adjust_product_stock
    #difference = invoice_detail.quantity.to_f - quantity.to_f
    self.product.impact_stock_from_delivery_note_detail(id_depot_id: invoice_detail.depot_id, dn_depot_id: depot_id, quantity: quantity)
    # if !invoice_detail.blank? && invoice_detail.depot_id == self.depot_id
    #   difference = invoice_detail.quantity.to_f - quantity.to_f
    #   self.product.rollback_reserved_stock(quantity: difference, depot_id: self.depot_id)  #Se descuenta diferencia restante de STOCK RESERVADO y se la suma a STOCK DISPONIBLE WTF(?)
    #   self.product.deliver_product(quantity: quantity, depot_id: self.depot_id, from: "Reservado")  #Agrega cantidad entregada en STOCK ENTREGADO y se la resta de STOCK RESERVADO ?
    # elsif !invoice_detail.blank? && invoice_detail.depot_id != self.depot_id
    #   self.product.rollback_reserved_stock(quantity: quantity.to_f, depot_id: self.depot_id) #Se descuenta cantidad entregada de STOCK RESERVADO y suma a STOCK DISPONIBLE WTF(?)
    #   self.product.deliver_product(quantity: quantity.to_f, depot_id: self.depot_id, from: "Disponible") #Agrega cantidad entregada en STOCK ENTREGADO y se la resta de STOCK DISPONIBLE ?
    # else
    #   self.product.deliver_product(quantity: quantity.to_f, depot_id: self.depot_id, from: "Disponible") #Agrega cantidad entregada en STOCK ENTREGADO y se la resta de STOCK DISPONIBLE ?
    # end
  end

  def depot_has_stock?
    stocks = self.depot.stocks.where(product_id: self.product_id)
    reservado = stocks.where(state: "Reservado").first.nil? ? 0 : stocks.where(state: "Reservado").first.quantity
    disponible = stocks.where(state: "Disponible").first.nil? ? 0 : stocks.where(state: "Disponible").first.quantity

    if !invoice_detail.blank? && invoice_detail.depot_id == self.depot_id
      if reservado < self.quantity.to_f
        errors.add(:quantity, "Se esta intentando entregar mayor cantidad que la que se reservo cuando se realizo la factura. Verifique depósito seleccionado. Si desea proceeder borre este detalle (fila) y cree uno nuevamente")
      end
    elsif !invoice_detail.blank? && invoice_detail.depot_id != self.depot_id
      if disponible < self.quantity.to_f
        errors.add(:quantity, "El deposito que seleccionó no tiene suficiente stock disponible. Disponible = #{disponible} #{self.product.measurement_unit_name}")
      end
    else
      if disponible < self.quantity.to_f
        errors.add(:quantity, "El deposito que seleccionó no tiene suficiente stock disponible. Disponible = #{disponible} #{self.product.measurement_unit_name}")
      end
    end
  end

  # def destroy
	# 	update_column(:active, false)
	# 	run_callbacks :destroy
	# end

end
