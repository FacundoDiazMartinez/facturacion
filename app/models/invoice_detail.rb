class InvoiceDetail < ApplicationRecord
  belongs_to :invoice
  belongs_to :product, optional: true
  belongs_to :depot, optional: true

  has_many :commissioners, dependent: :destroy

  accepts_nested_attributes_for :product, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :commissioners, reject_if: :all_blank, allow_destroy: true

  before_validation :check_product

  after_save :set_total_to_invoice
  after_validation :reserve_stock, if: Proc.new{|detail| detail.invoice.is_invoice? && quantity_changed?}
  after_destroy :remove_reserved_stock


  default_scope {where(active: true)}

  #validates_presence_of :invoice_id, message: "El detalle debe estar vinculado a una factura."
  validates_presence_of :product, message: "El detalle debe estar vinculado a un producto."
  validates_presence_of :quantity, message: "El detalle debe especificar una cantidad."
  validates_numericality_of :quantity, greater_than: 0.0, message: "La cantidad debe ser mayor a 0."
  validates_inclusion_of :measurement_unit, in: Product::MEASUREMENT_UNITS.keys, message: "Unidad de medida inválida.", if: Proc.new{|id| not id.product.nil?}
  validates_presence_of :measurement_unit, message: "Debe especificar la unidad de medida en el detalle de la factura.", if: Proc.new{|id| not id.product.nil?}
  validates_presence_of :price_per_unit, message: "Debe especificar la unidad de medida en el detalle de la factura."
  validates_numericality_of :price_per_unit, greater_than_or_equal_to: 0.0, message: "El precio por unidad debe ser igual o mayor a 0."
  validates_numericality_of :bonus_percentage, message: "El porcentage bonificado debe ser un número."
  validates_numericality_of :bonus_amount, message: "El monto abonado debe ser un número."
  validates_presence_of :subtotal, message: "El detalle debe tener un subtotal."
  validates_numericality_of :subtotal, greater_than_or_equal_to: 0.0, message: "El subtotal debe ser mayor o igual a 0."
  validates_presence_of :iva_aliquot, message: "Debe especificar una alicuota de I.V.A."
  validates_inclusion_of :iva_aliquot, in: Afip::ALIC_IVA.map{|k,v| k}, message: "Alícuota de I.V.A. inválida."
  validates_numericality_of :iva_amount, greater_than_or_equal_to: 0.0, message: "El monto I.V.A. debe ser mayor o igual a 0."
  validates_presence_of :iva_amount, message: "Debe especificar una alicuota de I.V.A." #Se pone asi pq el monto se calcula en base a la alicuota
  

  # TABLA
  #   create_table "invoice_details", force: :cascade do |t|
  #     t.bigint "invoice_id"
  #     t.bigint "product_id"
  #     t.float "quantity", default: 1.0, null: false
  #     t.string "measurement_unit", null: false
  #     t.float "price_per_unit", default: 0.0, null: false
  #     t.float "bonus_percentage", default: 0.0, null: false
  #     t.float "bonus_amount", default: 0.0, null: false
  #     t.float "subtotal", default: 0.0, null: false
  #     t.string "iva_aliquot"
  #     t.float "iva_amount"
  #     t.boolean "active", default: true, null: false
  #     t.datetime "created_at", null: false
  #     t.datetime "updated_at", null: false
  #     t.bigint "user_id"
  #     t.index ["invoice_id"], name: "index_invoice_details_on_invoice_id"
  #     t.index ["product_id"], name: "index_invoice_details_on_product_id"
  #     t.index ["user_id"], name: "index_invoice_details_on_user_id"
  #   end
  # TABLA

  #PROCESOS
    def check_product
        product.company_id          = invoice.company_id
        product.updated_by          = invoice.user_id
        product.created_by          = invoice.user_id
        product.price             ||= price_per_unit
        product.measurement_unit  ||= measurement_unit
        product.save
    end

    def set_total_to_invoice
      invoice.update_attribute(:total, invoice.sum_details)
    end

    def product_attributes=(attributes)
      prod = Product.unscoped.where(code: attributes[:code], company_id: attributes[:company_id]).first_or_initialize
      self.product = prod
      attributes.delete(:id) unless product.persisted?
      super
    end

    # def commissioners_attributes=(attributes)
    #   attributes.each do |num,c|
    #     if c["_destroy"] == "false"
    #       com = self.commissioners.where(invoice_detail_id: self.id, user_id: c["user_id"]).first_or_initialize
    #       com.percentage = c["percentage"]
    #       com.total_commission = 0
    #     else
    #       com = self.commissioners.where(invoice_detail_id: self.id, user_id: c["user_id"]).first
    #       if !com.nil?
    #         com.destroy
    #       end
    #     end
    #   end
    # end

    def product
      Product.unscoped{super}
    end

    def product_depots
      product.nil? ? [] : product.depots.map{|p| [p.name, p.id]}
    end

    def remove_reserved_stock
      self.product.rollback_reserved_stock(quantity: quantity, depot_id: depot_id)
    end

    def reserve_stock
      if quantity_change.nil? || new_record?
        self.product.reserve_stock(quantity: self.quantity, depot_id: depot_id)
      else
        dif = quantity_change.first.to_f - quantity_change.second.to_f 
        self.product.rollback_reserved_stock(quantity: dif, depot_id: depot_id)
      end
    end

  #PROCESOS

  #ATRIBUTOS
    def measurement_unit_value
      Product::MEASUREMENT_UNITS[measurement_unit.to_s]
    end

    def default_iva
      iva_aliquot.nil? ? "05" : iva_aliquot
    end
  #ATRIBUTOS


  #FUNCIONES
    def neto
      (subtotal / (1 + iva)).round(2)
    end

    def iva
      Afip::ALIC_IVA.map{|ai| ai.last unless ai.first != iva_aliquot.to_s}.compact.join().to_f
    end

    def destroy
      update_column(:active, false)
      run_callbacks :destroy
      freeze
    end
  #FUNCIONES

end
