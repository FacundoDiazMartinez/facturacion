class AccountMovementsController < ApplicationController
  before_action :set_client
  before_action :set_account_movement, only: [:show, :edit, :update, :destroy]

  # GET /account_movements
  # GET /account_movements.json
  def index
    @account_movements = @client.account_movements.search_by_cbte_tipo(params[:cbte_tipo]).search_by_date(params[:from], params[:to]).order("created_at ASC").paginate(page: params[:page], per_page: 25)
  end

  # GET /account_movements/1
  # GET /account_movements/1.json
  def show
  end

  # GET /account_movements/new
  def new
    @account_movement = AccountMovement.new
    #@account_movement.build_receipt(client_id: @client.id)
    #@account_movement.account_movement_payments.build
    DailyCash.current_daily_cash current_user.company_id
  end

  # GET /account_movements/1/edit
  # def edit
  # end

  # POST /account_movements
  # POST /account_movements.json
  def create

    @account_movement = @client.account_movements.new(account_movement_params)
    @account_movement.user_id = current_user.id
    @account_movement.company_id = current_user.company_id
    @account_movement.amount_available = @account_movement.total
    respond_to do |format|
      if @account_movement.save
        format.html { redirect_to client_account_movements_path(@client.id), notice: 'Movimiento generado correctamente.' }
        format.json { render :show, status: :created, location: @account_movement }
      else
        pp @account_movement.errors
        format.html { render :new }
        format.json { render json: @account_movement.errors, status: :unprocessable_entity }
      end
    end
  end



  # PATCH/PUT /account_movements/1
  # PATCH/PUT /account_movements/1.json
  # def update
  #   respond_to do |format|
  #     if @account_movement.update(account_movement_params)
  #       format.html { redirect_to client_account_movements_path(@client.id), notice: 'Movimiento actualizado correctamente.' }
  #       format.json { render :show, status: :ok, location: @account_movement }
  #     else
  #       format.html { render :edit }
  #       format.json { render json: @account_movement.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end

  # DELETE /account_movements/1
  # DELETE /account_movements/1.json
  def destroy
    @account_movement.destroy
    respond_to do |format|
      format.html { redirect_to client_account_movements_url(@client.id), notice: 'Movimiento eliminado correctamente.' }
      format.json { head :no_content }
    end
  end

  def export
    @account_movements = @client.account_movements.where(created_at: params[:since].to_date.beginning_of_day..params[:to].to_date.end_of_day).order("created_at ASC")
    respond_to do |format|
      format.xlsx { response.headers['Content-Disposition'] = 'attachment; filename="Estado de Cuenta - Elasticos M&M SRL.xlsx"' }
    end
  end

  private

    def set_client
      @client = current_user.company.clients.find(params[:client_id])
    end
    # Use callbacks to share common setup or constraints between actions.
    def set_account_movement
      @account_movement = @client.account_movements.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def account_movement_params
      params.require(:account_movement).permit(:total, :debe, :haber, :cbte_tipo, receipt_attributes:
        [:id, :sale_point_id, :client_id, :company_id, :total],
        account_movement_payments_attributes: [:id, :payment_date, :type_of_payment,
          cash_payment_attributes: [:id, :total],
          card_payment_attributes: [:id, :credit_card_id, :subtotal, :installments, :interest_rate_percentage, :interest_rate_amount, :total],
          bank_payment_attributes: [:id, :bank_id, :total],
          cheque_payment_attributes: [:id, :state, :expiration, :total, :observation, :origin, :entity, :number],
          retention_payment_attributes: [:id, :number, :total, :observation]
        ]
      )
    end
end
