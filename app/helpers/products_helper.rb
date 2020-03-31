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
			link_to product.category_name, edit_supplier_path(product.supplier_id)
		else
			product.supplier_name
		end
	end

	def product_stock_helper(product)
	  if not product.minimum_stock.blank?
			if product.available_stock <= product.minimum_stock
				return "<div class='text-danger'>#{product.available_stock}</div>".html_safe
			else
				return "<div class='text-success'>#{product.available_stock}</div>".html_safe
			end
		else
			return "<div class='text-success'>#{product.available_stock}</div>".html_safe
	  end
	end

end
