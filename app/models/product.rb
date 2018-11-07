class Product < ApplicationRecord
  	belongs_to :product_category, optional: true
  	belongs_to :company
  	has_many   :stocks
  	has_many   :depots, through: :stocks
  	has_many   :invoice_details
  	has_many   :invoice, through: :invoice_details
  	has_many   :purchase_order_details
  	has_many   :purchase_orders, through: :purchase_order_details

    default_scope {where(active:true)}

  	validates_presence_of :price, message: "Debe ingresar el precio del producto."
  	validates_numericality_of :price, message: "El precio solo debe contener caracteres numéricos."
  	validates_presence_of :code, message: "Debe ingresar un código en el producto."
  	validates_presence_of :name, message: "El nombre del producto no puede estar en blanco."
  	validates_presence_of :company_id, message: "El producto debe estar asociado a su compañía."


  	MEASUREMENT_UNITS = {
	  	"1" => "kilogramos",
	  	"2" => "metros",
	  	"3" => "metros cuadrados",
	  	"4" => "metros cúbicos",
	  	"5" => "litros",
	  	"6" => "1000 kWh",
	  	"7" => "unidades",
	  	"8" => "pares",
	  	"9" => "docenas",
	  	"10" => "quilates",
	  	"11" => "millares",
	  	"14" => "gramos",
	  	"15" => "milimetros",
	  	"16" => "mm cúbicos",
	  	"17" => "kilómetros",
	  	"18" => "hectolitros",
	  	"20" => "centímetros",
	  	"25" => "jgo. pqt. mazo naipes",
	  	"27" => "cm cúbicos",
	  	"29" => "toneladas",
	  	"30" => "dam cúbicos",
	  	"31" => "hm cúbicos",
	  	"32" => "km cúbicos",
	  	"33" => "microgramos",
	  	"34" => "nanogramos",
	  	"35" => "picogramos",
	  	"41" => "miligramos",
	  	"47" => "mililitros",
	  	"48" => "curie",
	  	"49" => "milicurie",
	  	"50" => "microcurie",
	  	"51" => "uiacthor",
	  	"52" => "muiacthor",
	  	"53" => "kg base",
	  	"54" => "gruesa",
	  	"61" => "kg bruto",
	  	"62" => "uiactant",
	  	"63" => "muiactant",
	  	"64" => "uiactig",
	  	"65" => "muiactig",
	  	"66" => "kg activo",
	  	"67" => "gramo activo",
	  	"68" => "gramo base",
	  	"96" => "packs",
	  	"98" => "otras unidades"
	}
	validates_inclusion_of :measurement_unit, :in => MEASUREMENT_UNITS.keys, if: Proc.new{|p| not p.measurement_unit.nil?}

  	#ATRIBUTOS
	  	def full_name
	  		"#{code} - #{name}"
	  	end

	  	def photo
			read_attribute("photo") || "/images/default_product.jpg"
		end

		def category_name
			product_category.nil? ? "Sin categoría" : product_category.name
		end

		def available_stock
			stocks.where(state: "Disponible").count
		end
	#ATRIBUTOS

	#PROCESOS
		def self.create params
			pp "NTEOOOOOOOOO"
			product = Product.where(company_id: company_id, code: code).first_or_initialize
			if produc.new_record?
				super
			else
				update(params)
			end
		end

    def destroy
      update_column(:active,false)
    end
	#PROCESOS
end
