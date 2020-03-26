class ProductUnscoped < Product
	self.table_name = "products"

	def self.default_scope
    where(tipo: "Producto")
 	end
end
