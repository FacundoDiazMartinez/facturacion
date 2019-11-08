class Service < Product

  # validates_uniqueness_of :id, scope: [:company_id, :active], message: "Ya existe un servicio con el mismo identificador."
  # validates_uniqueness_of :name, scope: [:company_id, :active], message: "Ya existe un servicio con el mismo nombre."


  before_validation :set_tipo

  self.table_name =  "products"

  def self.default_scope
    where(active: true, tipo: "Servicio")
  end

  def self.permitted_params
		[:product_category_name, :code, :name, :cost_price, :iva_aliquot, :net_price, :price, :measurement, :measurement_unit]
	end

  #IMPORTAR EXCEL o CSV
  def self.save_excel file, current_user
    #TODO Añadir created_by y updated_by
      spreadsheet = open_spreadsheet(file)
      excel = []
      (2..spreadsheet.last_row).each do |r|
        excel << spreadsheet.row(r)
      end
      header = self.permitted_params
      categories = {}
      current_user.company.product_categories.map{|pc| categories[pc.name] = pc.id}
      delay.load_services(excel, header, categories, current_user)

  end

  def self.load_services spreadsheet, header, categories, current_user
    services 	= []
    invalid 	= []
    (0..spreadsheet.size - 1).each do |i|
            row = Hash[[header, spreadsheet[i]].transpose]
            service = where(code: row[:code], company_id: current_user.company_id ).first_or_initialize
            if categories["#{row[:product_category_name]}"].nil?
              pc = ProductCategory.where(name: row[:product_category_name], company_id: current_user.company_id).first_or_initialize
              if pc.save
                product_category_id = pc.id
                categories["#{row[:product_category_name]}"] = product_category_id
              else
                pp pc.errors
              end
            end
            service.product_category_id = categories["#{row[:product_category_name]}"]
            service.supplier_id 		  	= nil
            service.supplier_code 			= nil
            service.code                = row[:code]
            service.name 				        = row[:name]
            service.cost_price 			    = row[:cost_price].round(2) unless row[:cost_price].nil?
            service.net_price 			    = row[:net_price].round(2) unless row[:net_price].nil?
            service.price 				      = row[:price].round(2) unless row[:price].nil?
            service.measurement_unit 	  = "unidad"
            service.iva_aliquot 		    = "05"
            service.company_id 			    = current_user.company_id
            service.created_by 			    = current_user.id
            service.updated_by 			    = current_user.id
            if service.valid?
              service.save!
            else
              service.errors
              invalid << i
            end
        end
        return_process_result(invalid, current_user)
  end

  def set_tipo
    self.tipo = "Servicio"
  end

end
