class Staff::UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy, :approve, :disapprove, :roles, :commission, :edit_commission, :update_commission]
  before_action :set_commission, only: [:edit_commission, :update_commission]
  skip_before_action :authenticate_user!, only: :autocomplete_company_code

  # GET /users
  # GET /users.json
  def index
    @users = current_user.company.users.search_by_name(params[:name]).search_by_document(params[:document_number]).search_by_state(params[:state]).paginate(per_page: 10, page: params[:page])
  end

  # GET /users/1
  # GET /users/1.json
  def show
    @activities = @user.user_activities.order("updated_at DESC").paginate(page: params[:page], per_page: 5)
  end

  def edit

  end

  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to users_path, notice: 'Actualizado correctamente' }
      else
        format.html {redirect_to users_path, alert: 'Error al actualizar'}
      end
    end
  end

  def destroy
    if current_user.id != @user.id
      @user.destroy
      respond_to do |format|
        format.html { redirect_to users_path, notice: 'El usuario fue eliminado correctamente.' }
        format.json { head :no_content }
      end
    else
      respond_to do |format|
        format.html { redirect_to users_path, alert: 'Un usuario no puede eliminarse a si mismo.' }
        format.json { head :no_content }
      end
    end

  end

  def approve
    if current_user.has_management_role?
      respond_to do |format|
        if @user.update(approved: true)
          format.html { redirect_to users_path, notice: "El usuario ahora pertenece a su empresa." }
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
          format.html { redirect_to users_path, notice: "El usuario ya no tiene acceso a su empresa." }
        else
          format.html {render :show}
        end
      end
    end
  end

  def roles

  end

  def commission
    @commissions = @user.commissioners.includes(invoice_detail: :invoice).search_by_date(params[:from], params[:to]).search_by_cbte_number(params[:cbte_number]).paginate(page: params[:page], per_page: 10)
    @commission_sum = @user.commissioners.search_by_date(params[:from], params[:to]).search_by_cbte_number(params[:cbte_number]).sum(:total_commission)
  end

  def edit_commission

  end

  def update_commission
    respond_to do |format|
      if @commission.update(commission_params)
        format.html {redirect_to commission_user_path(@user.id), notice: "Comisión actualizada con éxito."}
      else
        format.html {render :edit_commission}
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

    def set_commission
      @commission = @user.commissioners.find(params[:commission_id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:first_name, :last_name, :dni, :birthday, :address, :avatar, :phone, :mobile_phone, :postal_code, :province_id, :locality_id, user_roles_attributes: [:id, :role_id, :_destroy])
    end

    def commission_params
      params.require(:commissioner).permit(:percentage)
    end
end
