class ClientsController < ApplicationController
	before_action :set_client, only: [:edit, :update]

	def new
		@client = Client.new
	end

	def edit
		
	end

	def create
		@client = current_user.company.clients.new(client_params)
		respond_to do |format|
			format.html { redirect_to @client, notice: 'Cliente creado con éxito.' }
        	format.json { render :show, status: :created, location: @company }
      	else
        	format.html { render :new }
        	format.json { render json: @company.errors, status: :unprocessable_entity }
      	end
	end

	def update
		
	end

	protected
		def set_client
			@client = current_user.clients.find(params[:id])
		end

		def client_params
			params.require(:client).permit(:name, :document_type, :document_number, :birthday, :phone, :mobile_phone, :email, :address, :iva_cond)
		end
end