class Staff::RolesController < ApplicationController
  before_action :set_role, only: [:show, :edit, :update, :destroy]

  def index
    @roles = current_company.roles.paginate(per_page: 10, page: params[:page])
  end

  def show
    @users = @role.users.paginate(per_page: 40, page: params[:page])
    @permissions = @role.role_permissions
  end

  def new
    @role = Role.new
  end

  def edit
  end

  def create
    @role = current_company.roles.new(role_params)
    if @role.save
      redirect_to roles_path, notice: 'Rol registrado con éxito'
    else
      render :new
    end
  end

  def update
    if @role.update(role_params)
      redirect_to @role, notice: 'Rol actualizado.'
    else
      render :edit
    end
  end

  private
    def set_role
      @role = current_company.roles.find(params[:id])
    end

    def role_params
      params.require(:role).permit(:name)
    end
end
