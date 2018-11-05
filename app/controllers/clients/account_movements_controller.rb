class Clients::AccountMovementsController < ApplicationController

	before_action :set_client

	def index
		@account_movements =  @client.account_movements.order("created_at ASC")
	end

	protected
		def set_client
			@client = current_user.company.clients.find(params[:id])
		end
end