module ProductsHelper

	def category_with_link product
		if product.supplier_id.blank? 
			product.category_name
		else
			if product.product_category.present?
				link_to product.category_name, product_category_path(product.product_category_id)
			else
				
			end
		end
	end

	def supplier_with_link product
		if product.supplier_id.blank? 
			product.supplier_name
		else
			link_to product.category_name, supplier_path(product.supplier_id)
		end
	end

end
