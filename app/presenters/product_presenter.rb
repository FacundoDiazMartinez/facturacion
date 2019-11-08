class ProductPresenter
	attr_reader :sales_for_last_year

	def initialize(product)
		@product = product
	end

	def sales_for_last_year
	  invoices = 0
	  product = @product.id
	  company = @product.company_id
	  año = Date.current.year-1
	  invoices = InvoiceDetail.joins(:invoice).where(product_id: product).where(invoices: {company_id: company, cbte_tipo: ['01','06','11']}).where("to_date(cbte_fch, 'dd/mm/YYYY') BETWEEN ? AND ?", "#{año}-01-01", "#{año}-12-31").sum(:quantity)
	  credit_notes = InvoiceDetail.joins(:invoice).where(product_id: product).where(invoices: {company_id: company, cbte_tipo: ['03','08','13']}).where("to_date(cbte_fch, 'dd/mm/YYYY') BETWEEN ? AND ?", "#{año}-01-01", "#{año}-12-31").sum(:quantity)
	  return invoices - credit_notes
 	end

 	def sales_for_current_year
	  invoices = 0
	  product = @product.id
	  company = @product.company_id
	  año = Date.current.year
	  invoices = InvoiceDetail.joins(:invoice).where(product_id: product).where(invoices: {company_id: company, cbte_tipo: ['01','06','11']}).where("to_date(cbte_fch, 'dd/mm/YYYY') BETWEEN ? AND ?", "#{año}-01-01", "#{año}-12-31").sum(:quantity)
	  credit_notes = InvoiceDetail.joins(:invoice).where(product_id: product).where(invoices: {company_id: company, cbte_tipo: ['03','08','13']}).where("to_date(cbte_fch, 'dd/mm/YYYY') BETWEEN ? AND ?", "#{año}-01-01", "#{año}-12-31").sum(:quantity)
	  return invoices - credit_notes
 	end

 	def sales_per_month
 		sales_per_month = []
 		Date::MONTHNAMES.drop(1).each_with_index do |month, i|
 			product = @product.id
	  	company = @product.company_id
 			fecha = Date.new(Date.today.year,i+1,1)
	  	invoices = InvoiceDetail.joins(:invoice).where(product_id: product).where(invoices: {company_id: company, cbte_tipo: ['01','06','11']}).where("to_date(cbte_fch, 'dd/mm/YYYY') BETWEEN ? AND ?", fecha.beginning_of_month, fecha.end_of_month).sum(:quantity)
 			credit_notes = InvoiceDetail.joins(:invoice).where(product_id: product).where(invoices: {company_id: company, cbte_tipo: ['03','08','13']}).where("to_date(cbte_fch, 'dd/mm/YYYY') BETWEEN ? AND ?", fecha.beginning_of_month, fecha.end_of_month).sum(:quantity)
 			total = invoices - credit_notes
 			sales_per_month << total
 		end
 		sales_per_month
 	end

end
