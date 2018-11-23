class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy, :approve, :disapprove]
  skip_before_action :authenticate_user!, only: :autocomplete_company_code

  # GET /users
  # GET /users.json
  def index
    @users = current_user.company.users.paginate(per_page: 10, page: params[:page])
  end

  # GET /users/1
  # GET /users/1.json
  def show
    @activities = @user.user_activities.paginate(page: params[:activity_page], per_page: 10)
  end

  def approve
    if current_user.has_management_role?
      respond_to do |format|
        if @user.update(approved: true)
          format.html { redirect_to @user, notice: "El usuario ahora pertenece a su empresa." }
        else
          format.html {render :show}
        end
      end
    end
  end

  def disapprove
    if current_user.has_management_role?
      respond_to do |format|
        if @user.update(approved: false)
          format.html { redirect_to @user, notice: "El usuario ya no tiene acceso a su empresa." }
        else
          format.html {render :show}
        end
      end
    end
  end

  def autocomplete_company_code
    term = params[:term]
    pp companies = Company.where('code = ?', term).order(:name).all
    render :json => companies.map { |company| {:id => company.id, :label => company.name, :value => company.name} }
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = current_user.company.users.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:first_name, :last_name, :dni, :birthday, :address, :avatar, :phone, :mobile_phone, :postal_code, :province_id, :locality_id)
    end
end
