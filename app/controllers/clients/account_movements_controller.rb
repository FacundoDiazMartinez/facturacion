class Clients::AccountMovementsController < ApplicationController

	before_action :set_client

	def index
		@account_movements =  @client.account_movements.includes(:invoice, :receipt).search_by_cbte_tipo(params[:cbte_tipo]).search_by_date(params[:from], params[:to]).order("created_at DESC").paginate(page: params[:page], per_page: 10)
	end

	def add_payment
		if current_user.company.daily_cashes.search_by_date(nil).blank?
			session[:return_to] ||= request.referer
			redirect_to daily_cashes_path(), alert: "Primero debe abrir la caja diaria."
		else
			if !current_user.company.daily_cashes.search_by_date(nil).state == "Abierta"
				session[:return_to] ||= request.referer
				redirect_to daily_cashes_path(), alert: "Primero debe abrir la caja diaria."
			end
		end
	end

	def create_payment
		respond_to do |format|
	      	if @client.update(client_params)
	        	format.html {redirect_to client_account_movements_path(@client.id), notice: "Pago agregado correctamente."}
	      	else
	      		format.html { render :add_payment}
	      	end
	    end
	end

	protected
		def set_client
			@client = current_user.company.clients.find(params[:id])
		end

		def client_params
			params.require(:client).permit(invoices_attributes: [:id, income_payments_attributes:[:id, :type_of_payment, :total, :payment_date, :_destroy]])
		end
end
