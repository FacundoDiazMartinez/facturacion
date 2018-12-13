class RolePermissionsController < ApplicationController
  load_and_authorize_resource
  before_action :set_role
  before_action :set_role_permission, only: [:show, :edit, :update, :destroy]

  autocomplete :permission, :description, :limit => 10

  # GET /role_permissions
  # GET /role_permissions.json
  def index
    @friendly_names = Permission.joins(:friendly_name).includes(:friendly_name).order("friendly_names.name").all.map{ |p| [p.friendly_name.name]}.uniq.reduce(:+).compact

    @role_permissions = @role.permissions.all
    @permissions = Permission.all.map{ |p| p unless @role_permissions.map{ |rp| rp.id}.include?(p.id)}.compact
  end

  def autocomplete_permission_description
    term = params[:term]
    permission_ids = @role.permission_ids
    permission = Permission.search_by_description(term, permission_ids)
    render :json => permission.map { |permission| {id: permission.id, label: permission.description, value: permission.description} }
  end

  # GET /role_permissions/1
  # GET /role_permissions/1.json
  def show
  end

  # GET /role_permissions/new
  def new
    @role_permission = @role.role_permissions.new
  end

  # GET /role_permissions/1/edit
  def edit
  end

  # POST /role_permissions
  # POST /role_permissions.json
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
  end

  # DELETE /role_permissions/1
  # DELETE /role_permissions/1.json
  def destroy
    @role_permission.destroy
    respond_to do |format|
      format.html { redirect_to role_role_permissions_path(@role), notice: 'Permiso revocado' }
      format.js   { render :nothing => true }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_role_permission
      @role_permission = RolePermission.find(params[:id])
    end

    def set_role
      @role = Role.find(params[:role_id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def role_permission_params
      params.require(:role_permission).permit(:role_id, :permission_id)
    end
end
