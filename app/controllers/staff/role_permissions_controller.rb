class Staff::RolePermissionsController < ApplicationController
  load_and_authorize_resource
  before_action :set_role
  before_action :set_role_permission, only: [:show, :edit, :update, :destroy]

  autocomplete :permission, :description, :limit => 10

  def index
    @friendly_names = Permission.joins(:friendly_name).includes(:friendly_name).order("friendly_names.name").all.map{ |p| [p.friendly_name.name]}.uniq.reduce(:+).compact
    @role_permissions = @role.permissions.all.includes(:friendly_name)
    @permissions = Permission.all.includes(:friendly_name).map{ |p| p unless @role_permissions.map{ |rp| rp.id}.include?(p.id)}.compact
  end

  def autocomplete_permission_description
    term = params[:term]
    permission_ids = @role.permission_ids
    permission = Permission.search_by_description(term, permission_ids)
    render :json => permission.map { |permission| {id: permission.id, label: permission.description, value: permission.description} }
  end

  def show
  end

  def new
    @role_permission = @role.role_permissions.new
  end

  def edit
  end

  def create
    @role_permission = RolePermission.new(role_permission_params)

    respond_to do |format|
      if @role_permission.save
        format.html { redirect_to role_role_permissions_path(@role), notice: 'Permiso concedido' }
        format.json { render :show, status: :created, location: @role_permission }
      else
        format.html { render :new }
        format.json { render json: @role_permission.errors, status: :unprocessable_entity }
      end
    end
  end

  def toggle_association
    if @role.id != 1
      @permission = Permission.find(params[:permission_id])
      @role_permission = @role.role_permissions.where(
        permission_id:  @permission.id,
        role_id:        @role.id
      ).first

      if @role_permission
        ## si existe el permiso se destruye
        @role_permission.destroy
      else
        ## si no existe se guarda
        RolePermission.generate_new_role_permission(@role, @permission)

      end
    end
    respond_to do |format|
      format.js {
        index
        render :toggle_association
      }
    end
  end

  def destroy
    @role_permission.destroy
    respond_to do |format|
      format.html { redirect_to role_role_permissions_path(@role), notice: 'Permiso revocado' }
      format.js   { render :nothing => true }
      format.json { head :no_content }
    end
  end

  private
    def set_role_permission
      @role_permission = RolePermission.find(params[:id])
    end

    def set_role
      @role = Role.find(params[:role_id])
    end

    def role_permission_params
      params.require(:role_permission).permit(:role_id, :permission_id)
    end
end
