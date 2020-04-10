class Sales::AccountMovementsController < ApplicationController
  before_action :set_client
  before_action :set_account_movement, only: [:show, :edit, :update, :destroy]

  def index
    cantidad_por_pagina = 25
    account_movements   = @client.account_movements
    # if params[:page]
    #   pagina = params[:page]
    # else
    #   cantidad_registros  = account_movements.count
    #   ultima_pagina       = cantidad_registros/cantidad_por_pagina + (cantidad_registros%cantidad_por_pagina > 0 ? 1 : 0)
    #   pagina              = ultima_pagina
    # end
    pagina = params[:page] ## borrar esta línea si usamos el algoritmo de arriba
    @ultimo             = account_movements.order(tiempo_de_confirmacion: :asc).last
    @account_movements  = account_movements.search_by_cbte_tipo(params[:cbte_tipo]).search_by_date(params[:from], params[:to]).order(tiempo_de_confirmacion: :asc).order(created_at: :asc).paginate(page: pagina, per_page: cantidad_por_pagina)
  end

  def show
  end

  def create
    @account_movement             = @client.account_movements.new(account_movement_params)
    @account_movement.user_id     = current_user.id
    @account_movement.company_id  = current_company.id
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

  def set_account_movement
    @account_movement = @client.account_movements.find(params[:id])
  end

  def account_movement_params
    params.require(:account_movement).permit(:total, :debe, :haber, :cbte_tipo, receipt_attributes:
      [:id, :sale_point_id, :client_id, :company_id, :total],
      account_movement_payments_attributes: [:id, :payment_date, :type_of_payment,
        cash_payment_attributes: [:id, :total],
        card_payment_attributes: [:id, :credit_card_id, :subtotal, :installments, :interest_rate_percentage, :interest_rate_amount, :total],
        bank_payment_attributes: [:id, :bank_id, :total],
        cheque_payment_attributes: [:id, :state, :expiration, :issuance_date, :total, :observation, :origin, :entity, :number],
        retention_payment_attributes: [:id, :number, :total, :observation]
      ]
    )
  end
end
