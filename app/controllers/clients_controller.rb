class ClientsController < ApplicationController
	before_action :set_invoice, only: [:edit, :update]
	before_action :set_client, only: [:edit, :update]

	def new
		@client = Client.new
	end

	def edit
		
	end

	def create
		@client = current_user.company.clients.new(client_params)
		respond_to do |format|
			if @client.save
				format.html { redirect_to @client, notice: 'Cliente creado con éxito.' }
	        	format.json { render :show, status: :created, location: @company }
	      	else
	        	format.html { render :new }
	        	format.json { render json: @company.errors, status: :unprocessable_entity }
	      	end
	    end
	end

	def update
		client_exists = current_user.company.clients.where(document_type: params[:client][:document_type], document_number: params[:client][:document_number])
		if client_exists.empty?
			@client = @invoice.client
		else
			@client = client_exists.first
			@invoice.update_column(:client_id, @client.id)
		end
		respond_to do |format|
			if @client.update(client_params)
				format.html { redirect_to edit_invoice_path(@invoice.id), notice: 'Cliente creado con éxito.' }
				format.js 	{ render :edit }
	      	else
	        	format.html { render :edit }
	        	format.js 	{ render :edit }
	      	end
	    end
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