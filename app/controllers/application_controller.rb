class ApplicationController < ActionController::Base
  require 'exceptions.rb'

  before_action :configure_permitted_parameters, :authenticate_user!, if: :devise_controller?
  before_action :authenticate_user!, except: [:get_localities]
  before_action :redirect_to_company, except: [:get_localities]
  after_action :flash_to_headers

  def flash_to_headers
    flash_header = []
    unless flash.first.nil?
      flash_header = [flash.first.first, flash.first.last, SecureRandom.hex(4)]
    end
    response.headers['X-Flash'] = flash_header.to_json
  end

	def get_localities
		render json: Locality.where(province_id: params[:city_id]).order(:name).map{|l| [l.id, l.name]}
	end

  def redirect_to_company
    redirect_to root_path unless current_company
  end

  def current_company
    return current_user.company
  end
  helper_method :current_company

  rescue_from ::Exceptions::EmptySalePoint do |exception|
    session[:return_to] ||= request.path
    flash[:alert] =  "Primero debe crear al menos un punto de venta."
    redirect_to edit_company_path(current_user.company.id)
  end

  rescue_from ::Exceptions::DailyCashClose do |exception|
    session[:return_to] ||= request.path # Esto porque, por ejemplo, make_sale de Budget envía info en session[:return_to] y no debe cambiarse el valor.
    flash[:alert] =  "Primero debe abrir la caja diaria."
    redirect_to daily_cashes_path
  end

  rescue_from ::Exceptions::EmptyDepot do |exception|
    session[:return_to] ||= request.path
    flash[:alert] = "Primero debe cargar un deposito."
    redirect_to depots_path()
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:account_update, keys: [:first_name, :last_name, :dni, :birthday, :address, :phone, :mobile_phone, :province_id, :locality_id, :postal_code])
  end

  rescue_from CanCan::AccessDenied do |exception|
    flash[:danger] = "No posee los permisos para realizar esta acción."
    redirect_to user_path(current_user)
  end

  def set_s3_direct_post
    @s3_direct_post = S3_BUCKET.presigned_post(key: "uploads/#{SecureRandom.uuid}/${filename}", success_action_status: '201', acl: 'public-read')
  end
end
