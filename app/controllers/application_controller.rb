class ApplicationController < ActionController::Base

	def get_localities
		render json: ::Afip::CTG.new().consultar_localidades(params[:city_id])
	end
end
