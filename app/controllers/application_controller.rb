class ApplicationController < ActionController::Base
 before_action :authenticate_user!

	def get_localities
		render json: ::Afip::CTG.new().consultar_localidades(params[:city_id])
	end
end
