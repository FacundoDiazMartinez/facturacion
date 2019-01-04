class DailyCashesController < ApplicationController
  before_action :set_daily_cash, only: [:show, :edit, :update, :destroy]
  # GET /daily_cashes
  # GET /daily_cashes.json
  def index
    @daily_cash = current_user.company.daily_cashes.search_by_user(params[:user]).search_by_date(params[:date] || Date.today)
    @daily_cash_movements = DailyCash.all_daily_cash_movements(@daily_cash).paginate(page: params[:page], per_page: 10)
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
    respond_to do |format|
      if @daily_cash.save
        format.html { redirect_to daily_cashes_path, notice: "Apertura de caja exitosa." }
      else
        format.html { render :new }
      end
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
    # Use callbacks to share common setup or constraints between actions.
    def set_daily_cash
      @daily_cash = current_user.company.daily_cashes.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def daily_cash_params
      params.require(:daily_cash).permit(:state, :initial_amount, :final_amount)
    end
end
