class ApplicationController < ActionController::Base
 before_action :configure_permitted_parameters, :authenticate_user!, if: :devise_controller?
 before_action :authenticate_user!
 before_action :redirect_to_company, except: [:get_localities]

	def get_localities
		render json: Locality.where(province_id: params[:city_id]).order(:name).map{|l| [l.id, l.name]}
	end


  protected
  def redirect_to_company
    if current_user
      if not current_user.has_company?
        redirect_to root_path
      end
    end
  end

  def configure_permitted_parameters
    # devise_parameter_sanitizer.permit(:sign_up, keys: [:username])
    # devise_parameter_sanitizer.permit(:sign_in, keys: [:username])
    devise_parameter_sanitizer.permit(:account_update, keys: [:first_name, :last_name, :dni, :birthday, :address, :phone, :mobile_phone, :province_id, :locality_id, :postal_code])
  end

  rescue_from CanCan::AccessDenied do |exception|
    flash[:danger] = "Acceso denegado. No posee los permisos para realizar esta acción."
    redirect_to user_path(current_user)
  end

  def set_s3_direct_post
    @s3_direct_post = S3_BUCKET.presigned_post(key: "uploads/#{SecureRandom.uuid}/${filename}", success_action_status: '201', acl: 'public-read')
  end
end
