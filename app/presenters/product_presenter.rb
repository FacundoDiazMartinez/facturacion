class ProductPresenter
	attr_reader :sales_for_last_year

	def initialize(product)
		@product = product
	end

	def sales_for_last_year
	  invoices = 0
	  product = @product.id
	  company = @product.company_id
	  invoices = InvoiceDetail.joins(:invoice).where(product_id: product).where(invoices: {company_id: company, cbte_tipo: ['01','06','11'], cbte_fch: (Date.today.at_beginning_of_year-1).to_s .. (Date.today.at_end_of_year-1).to_s}).sum(:quantity)
	  credit_notes = InvoiceDetail.joins(:invoice).where(product_id: product).where(invoices: {company_id: company, cbte_tipo: ['03','08','13'], cbte_fch: (Date.today.at_beginning_of_year-1).to_s .. (Date.today.at_end_of_year-1).to_s}).sum(:quantity)
	  return invoices - credit_notes
 	end

 	def sales_for_current_year
	  invoices = 0
	  product = @product.id
	  company = @product.company_id
	  invoices = InvoiceDetail.joins(:invoice).where(product_id: product).where(invoices: {company_id: company, cbte_tipo: ['01','06','11'], cbte_fch: (Date.today.at_beginning_of_year).to_s .. (Date.today.at_end_of_year).to_s}).sum(:quantity)
	  credit_notes = InvoiceDetail.joins(:invoice).where(product_id: product).where(invoices: {company_id: company, cbte_tipo: ['03','08','13'], cbte_fch: (Date.today.at_beginning_of_year).to_s .. (Date.today.at_end_of_year).to_s}).sum(:quantity)
	  return invoices - credit_notes
 	end
end