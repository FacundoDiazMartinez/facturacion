module ProductManager
  class Importer < ApplicationService
    # params[:file], params[:supplier_id], current_user, params[:depot_id], params[:type_of_movement]

    def initialize(file, supplier_id, user, depot_id, type_of_movement)
      @file             = file
      @supplier_id      = supplier_id
      @user             = user
      @depot_id         = depot_id
      @type_of_movement = type_of_movement
    end

    def call
      ActiveRecord::Base.transaction do
        save_excel(@file, @supplier_id, @user, @depot_id, @type_of_movement)
      end
    end

    private

    def save_excel(file, supplier_id, current_user, depot_id, type_of_movement)
    	spreadsheet = open_spreadsheet(file)
    	excel = []
    	(2..spreadsheet.last_row).each do |r|
    		excel << spreadsheet.row(r)
    	end
    	header = permited_params
    	categories = {}
    	current_user.company.product_categories.map{|pc| categories[pc.name] = pc.id}
    	delay.load_products(excel, header, categories, current_user, supplier_id, depot_id, type_of_movement)
    end

    def load_products spreadsheet, header, categories, current_user, supplier_id, depot_id, type_of_movement
    	invalid 	= []
  		(0..spreadsheet.size - 1).each do |i|
    		row = Hash[[header, spreadsheet[i]].transpose]
    		product = Product.where(code: row[:code], company_id: current_user.company_id ).first_or_initialize
    		if categories["#{row[:product_category_name]}"].nil?
    			pc = ProductCategory.where(name: row[:product_category_name], company_id: current_user.company_id).first_or_initialize
    			if pc.save
    				product_category_id = pc.id
    				categories["#{row[:product_category_name]}"] = product_category_id
    			end
    		end
  			iva_producto = row[:iva_aliquot].nil? ? '21' : row[:iva_aliquot]
    		product.supplier_id 		  	= supplier_id
    		product.product_category_id = categories["#{row[:product_category_name]}"]
    		product.code 				      	= row[:code]
    		product.supplier_code 			= row[:supplier_code]
    		product.name 				      	= row[:name]
  			if row[:net_price].nil?
  				unless row[:price].nil?
  					product.net_price = ((row[:price].round(2) * 100) / (100 + iva_producto.to_f)).round(2)
  					if (row[:cost_price].nil? || row[:cost_price] != 0)
  						product.cost_price = product.net_price
  					end
  				end
  			else
  			  product.net_price					= row[:net_price].round(2)
  				product.cost_price				= row[:net_price].round(2)
  			end
  			product.gain_margin					= 0
    		product.price 				    	= row[:price].round(2) unless row[:price].nil?
    		product.measurement_unit 		= row[:measurement_unit].nil? ? '7' : Product::MEASUREMENT_UNITS.map{|k,v| k unless v != row[:measurement_unit]}.compact.join()
    		product.iva_aliquot 		  	= row[:iva_aliquot].nil? ? '05' : Afip::ALIC_IVA.map{|k,v| k unless (v*100 != row[:iva_aliquot])}.compact.join()
    		product.company_id 			  	= current_user.company_id
    		product.created_by 			  	= current_user.id
    		product.updated_by 			  	= current_user.id
    		if !product.save
    			invalid << [i, product.errors.full_messages]
    		else
    			unless depot_id.blank?
      			stock = product.stocks.where(depot_id: depot_id, state: "Disponible").first_or_initialize
            if type_of_movement == "0"
              stock.quantity = row[:stock] || 1
            else
              stock.quantity += row[:stock]
            end
      			stock.save
          end
    	  end
    	end
  		return_process_result(invalid, current_user)
  	end

    def open_spreadsheet(file)
      case File.extname(file.original_filename)
  	    when ".csv"  then Roo::Csv.new(file.path)
  	    when ".xls"  then Roo::Spreadsheet.open(file.path, extension: :xlsx)
  	    when ".xlsx" then Roo::Excelx.new(file.path)
  	    else raise "Tipo de archivo desconocido: #{file.original_filename}"
      end
  	end

    def return_process_result invalid, user
      if invalid.any?
        {
          'result' => false,
          'message' => 'Uno o mas productos no pudieron importarse.',
          'product_with_errors' => invalid
        }
        Notification.create_for_failed_import invalid, user
      else
        {
          'result' => true,
          'message' => 'Todos los productos fueron correctamente importados a la base de datos.',
          'product_with_errors' => []
        }
        Notification.create_for_success_import user
      end
    end

  	def open_spreadsheet(file)
      case File.extname(file.original_filename)
  	    when ".csv"  then Roo::Csv.new(file.path)
  	    when ".xls"  then Roo::Spreadsheet.open(file.path, extension: :xlsx)
  	    when ".xlsx" then Roo::Excelx.new(file.path)
  	    else raise "Tipo de archivo desconocido: #{file.original_filename}"
      end
  	end

    def permited_params
  		[:product_category_name, :code, :name, :supplier_code, :cost_price, :iva_aliquot, :net_price, :price, :measurement, :measurement_unit, :stock]
  	end
  end
end
