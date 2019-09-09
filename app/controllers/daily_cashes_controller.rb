class DailyCashesController < ApplicationController
  before_action :set_daily_cash, only: [:show, :edit, :update, :destroy]

  def index
    @daily_cash = current_user.company.daily_cashes.where(date: Date.today).search_by_flow(params[:flow]).search_by_user(params[:user]).first
    @daily_cash_movements = DailyCash.all_daily_cash_movements(@daily_cash, params[:user], params[:payment_type]).paginate(page: params[:page], per_page: 10)
  end

  def new
    @daily_cash = DailyCash.new
  end

  def edit
  end

  def create
    @daily_cash = current_user.company.daily_cashes.new(daily_cash_params)
    @daily_cash.current_user = current_user.id
    @daily_cash.date = Date.today
    @daily_cash.current_amount = @daily_cash.initial_amount
    if @daily_cash.save
      if session[:return_to].blank?
        redirect_to daily_cashes_path, notice: "Apertura de caja exitosa."
      else
        redirect_to session.delete(:return_to), params: session[:new_invoice], notice: "Ahora puede continuar con su operación."
      end
    else
      pp @daily_cash.errors
      render :new
    end
  end

  def update
    respond_to do |format|
      if @daily_cash.update(daily_cash_params)
        format.html {redirect_to daily_cashes_path, notice: "Movimiento realizado con éxito."}
      else
        format.html {render :edit}
      end
    end
  end

  private

  def set_daily_cash
    @daily_cash = current_user.company.daily_cashes.find(params[:id])
  end

  def daily_cash_params
    params.require(:daily_cash).permit(:state, :initial_amount, :final_amount)
  end
end
