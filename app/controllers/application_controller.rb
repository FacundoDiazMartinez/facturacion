class ApplicationController < ActionController::Base
 before_action :configure_permitted_parameters, :authenticate_user!, if: :devise_controller?

	def get_localities
		render json: Locality.where(province_id: params[:city_id]).map{|l| [l.id, l.name]}
	end


  protected

  def configure_permitted_parameters
    # devise_parameter_sanitizer.permit(:sign_up, keys: [:username])
    # devise_parameter_sanitizer.permit(:sign_in, keys: [:username])
    devise_parameter_sanitizer.permit(:account_update, keys: [:first_name, :last_name, :dni, :birthday, :address, :phone, :mobile_phone, :province, :city, :province, :postal_code])
  end

  def set_s3_direct_post
    @s3_direct_post = S3_BUCKET.presigned_post(key: "uploads/#{SecureRandom.uuid}/${filename}", success_action_status: '201', acl: 'public-read')
  end
end
