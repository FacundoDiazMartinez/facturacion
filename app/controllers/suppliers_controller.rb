class SuppliersController < ApplicationController
  before_action :set_supplier, only: [:show, :edit, :update, :destroy]

  # GET /suppliers
  # GET /suppliers.json
  def index
    set_suppliers
  end

  # GET /suppliers/1
  # GET /suppliers/1.json
  def show
  end

  # GET /suppliers/new
  def new
    @supplier = Supplier.new
  end

  # GET /suppliers/1/edit
  def edit
  end

  # POST /suppliers
  # POST /suppliers.json
  def create
    @supplier = current_user.company.suppliers.new(supplier_params)
    @supplier.created_by = current_user.id
    @supplier.updated_by = current_user.id
    @supplier.company = current_user.company
    respond_to do |format|
      if @supplier.save
        UserActivityManager::NewSupplierGenerator.call(@supplier)
        set_suppliers
        format.html { redirect_to @supplier, notice: 'Supplier was successfully created.' }
        format.json { render :show, status: :created, location: @supplier }
      else
        format.html { render :new }
        format.json { render json: @supplier.errors, status: :unprocessable_entity }
      end
      format.js     { render :set_supplier }
    end
  end

  # PATCH/PUT /suppliers/1
  # PATCH/PUT /suppliers/1.json
  def update
    @supplier.updated_by = current_user.id
    @supplier.company = current_user.company
    respond_to do |format|
      if @supplier.update(supplier_params)
        UserActivityManager::UpdatedSupplierGenerator.call(@supplier)
        set_suppliers
        format.html { redirect_to @supplier, notice: 'Supplier was successfully updated.' }
        format.json { render :show, status: :ok, location: @supplier }
      else
        format.html { render :edit }
        format.json { render json: @supplier.errors, status: :unprocessable_entity }
      end
      format.js     { render :set_supplier}
    end
  end

  # DELETE /suppliers/1
  # DELETE /suppliers/1.json
  def destroy
    @supplier.destroy
    respond_to do |format|
      format.html { redirect_to suppliers_url, notice: 'Supplier was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_supplier
      @supplier = current_user.company.suppliers.find(params[:id])
    end

    def set_suppliers
      @suppliers = current_user.company.suppliers.search_by_name(params[:name]).search_by_document(params[:document_number]).paginate(per_page: 5, page: params[:page])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def supplier_params
      params.require(:supplier).permit(:name, :document_type, :document_number, :phone, :mobile_phone, :address, :email, :cbu, :bank_name, :titular, :account_number, :iva_cond)
    end
end
