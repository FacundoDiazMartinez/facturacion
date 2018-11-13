class Invoices::ClientsController < ApplicationController
	before_action :set_invoice, only: [:edit, :update]
	before_action :set_client, only: [:edit, :update]

	def edit
		
	end

	def update
		@client = current_user.company.clients.find_by_full_document(client_params).first_or_initialize
		@client.set_attributes(params["client"].as_json)
		
		respond_to do |format|
			if @client.save
				@invoice.update_column(:client_id, @client.id)
				@invoice.update_column(:cbte_tipo, @invoice.available_cbte_type.last.last)
				@invoice.reload
				format.html { redirect_to edit_invoice_path(@invoice.id), notice: 'Cliente creado con éxito.' }
				format.js 	{ render :edit_client }
	      	else
	      		@client.errors.full_messages.each do |ce|
					@invoice.errors.add(:client, ce)
				end
	        	format.html { render :edit }
	        	format.js 	{ render :edit_client }
	      	end
	    end
	end

	def autocomplete_document
		term = params[:term]
    	clients = current_user.company.clients.where('document_number ILIKE ?', "%#{term}%").all
    	render :json => clients.map { |client| client.attributes.merge({"label" => client.name}).except("company_id", "active", "created_at", "updated_at", "saldo") }
	end

	protected

		def set_invoice
			@invoice = current_user.company.invoices.find(params[:invoice_id])
		end

		def set_client
			@client = @invoice.client
		end

		def client_params
			params.require(:client).permit(:name, :document_type, :document_number, :birthday, :phone, :mobile_phone, :email, :address, :iva_cond)
		end
end