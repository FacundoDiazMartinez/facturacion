class Staff::RolesController < ApplicationController
  before_action :set_role, only: [:show, :edit, :update, :destroy]

  def index
    @roles = current_user.company.roles.paginate(per_page: 10, page: params[:page])
  end

  def show
  end

  def new
    @role = Role.new
  end

  def edit
  end

  def create
    @role = current_user.company.roles.new(role_params)
    respond_to do |format|
      if @role.save
        format.html { redirect_to roles_path, notice: 'Rol creado exitosamente' }
        format.json { render :show, status: :created, location: @role }
      else
        format.html { render :new }
        format.json { render json: @role.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @role.update(role_params)
        format.html { redirect_to @role, notice: 'Rol actualizado.' }
        format.json { render :show, status: :ok, location: @role }
      else
        format.html { render :edit }
        format.json { render json: @role.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @role.destroy
    respond_to do |format|
      format.html { redirect_to roles_url, notice: 'Rol destruido.' }
      format.json { head :no_content }
    end
  end

  private
    def set_role
      @role = current_user.company.roles.find(params[:id])
    end

    def role_params
      params.require(:role).permit(:name)
    end
end
