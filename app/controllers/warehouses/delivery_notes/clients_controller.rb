class Warehouses::DeliveryNotes::ClientsController < ApplicationController
	before_action :set_delivery_note, only: [:update]  #Se necesita un delivery_note porque al renderizar el client_column pregunta si el delivery_note es editable
	before_action :set_client, only: [:edit, :update]

	def show
		@client = current_user.company.clients.find(params[:id])
	end

	def edit

	end

	def update
		@client 		= current_user.company.clients.find_by_full_document(client_params).first_or_initialize
		@client.set_attributes(params["client"].as_json)
		@client.user_id = current_user.id
		respond_to do |format|
			if @client.save
				format.html { render :back, notice: 'Cliente creado con éxito.' }
				format.js 	{ render :edit_client }
	      	else
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

		def set_delivery_note
			if params[:delivery_note_id].blank?
				@delivery_note = DeliveryNote.new
			else
				@delivery_note = current_user.company.delivery_notes.find(params[:delivery_note_id])
			end
		end

		def set_client
			@client = current_user.company.clients.find(params[:id])
		end

		def client_params
			params.require(:client).permit(:name, :document_type, :document_number, :birthday, :phone, :mobile_phone, :email, :address, :iva_cond)
		end
end
