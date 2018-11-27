class InvoiceDetail < ApplicationRecord
  belongs_to :invoice
  belongs_to :product, optional: true

  accepts_nested_attributes_for :product, reject_if: :all_blank, allow_destroy: true

  before_validation :check_product

  after_save :set_total_to_invoice

  default_scope {where(active: true)}

  #PROCESOS
    def check_product
      if new_record?
        product.company_id = invoice.company_id
        product.save
        if not product.errors.any?
          self.price_per_unit   = product.price
          self.measurement_unit = product.measurement_unit
        end
      end
    end

    #def destroy
      #update_column(:active,false)
    #end

    def set_total_to_invoice
      invoice.update_attribute(:total, invoice.sum_details)
    end

    def product_attributes=(attributes)
      if !attributes['id'].blank?
        self.product = Product.find(attributes['id'])
      end
      super
    end

    def product
      Product.unscoped{super}
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
