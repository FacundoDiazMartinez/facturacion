class Clients::AccountMovementsController < ApplicationController

	before_action :set_client

	def index
		@account_movements =  @client.account_movements.search_by_cbte_tipo(params[:cbte_tipo]).search_by_date(params[:from], params[:to]).order("created_at DESC").paginate(page: params[:page], per_page: 10)
	end

	def add_payment
		
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
			params.require(:client).permit(invoice_attributes: [:id, payment_attributes:[:id, :type_of_payment, :total, :payment_date, :_destroy]])
		end
end