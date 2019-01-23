class PurchaseOrderMailer < ApplicationMailer

	def send_mail purchase_order, email, company
		@purchase_order = purchase_order
		Product.unscoped do
	      @group_details = @purchase_order.purchase_order_details.includes(:product).in_groups_of(20, fill_with= nil)
	    end
		attachments['orden_de_compra.pdf'] = render_to_string(pdf: "orden_de_compra.pdf", template: 'purchase_orders/show.pdf.erb', layout: 'pdf.html')
		mail to: email, subject: "Orden de Compra - #{company.name}"
	end
end
