class PurchaseOrderDetailsController < PurchaseOrdersController
	before_action :set_purchase_order_detail, only: [:edit, :update]


	protected
		def set_purchase_order_detail
			@purchase_order_detail = current_user.company.purchase_orders.find(params[:purchase_order_id]).details.find(params[:id])
		end
end