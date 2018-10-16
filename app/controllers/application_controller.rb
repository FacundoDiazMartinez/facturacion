class ApplicationController < ActionController::Base
 before_action :configure_permitted_parameters, :authenticate_user!, if: :devise_controller?

	def get_localities
		render json: ::Afip::CTG.new().consultar_localidades(params[:city_id])
	end

  protected

  def configure_permitted_parameters
    # devise_parameter_sanitizer.permit(:sign_up, keys: [:username])
    # devise_parameter_sanitizer.permit(:sign_in, keys: [:username])
    devise_parameter_sanitizer.permit(:account_update, keys: [:first_name, :last_name, :dni, :birthday, :address, :phone, :mobile_phone, :province, :city, :province, :postal_code])
  end

end
