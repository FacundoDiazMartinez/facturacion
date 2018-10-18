class ClientsController < ApplicationController
	before_action :set_client, only: [:edit, :update]

	def new
		@client = Client.new
	end

	def edit
		
	end

	def create
		
	end

	def update
		
	end

	protected
		def set_client
			@client = current_user.clients.find(params[:id])
		end
end