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
		client_exists = current_user.company.clients.where(client_params)
		if client_exists.empty? #Si no existe
			@client = current_user.company.clients.create(client_params)
		else
			@client = client_exists.first
		end
		@invoice.update_column(:client_id, @client.id)
		@invoice.update_column(:cbte_tipo, @invoice.available_cbte_type.last.last)
		respond_to do |format|
			if @client.update(client_params)
				format.html { redirect_to edit_invoice_path(@invoice.id), notice: 'Cliente creado con éxito.' }
				format.js 	{ render :edit_client }
	      	else
	        	format.html { render :edit }
	        	format.js 	{ render :edit_client }
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