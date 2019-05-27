class DailyCashMovementsController < ApplicationController
	before_action :set_daily_cash_movement, only: [:show, :edit, :update, :destroy]

  	def show
  	end

  	def new
  		@daily_cash_movement = current_user.daily_cash_movements.build()
      @daily_cash_movement.date = Time.now
  	end

  	def edit
  		
  	end

  	def create
  		@daily_cash_movement = current_user.daily_cash_movements.build(daily_cash_movement_params)
      @daily_cash_movement.set_initial_values
  		respond_to do |format|
  			if @daily_cash_movement.save
  				format.html { redirect_to daily_cashes_path, notice: "Movimiento generado con éxito."}
  			else
  				format.html { render :new}
  			end
  		end
  	end

  	def update
  		respond_to do |format|
  			if @daily_cash_movement.update(daily_cash_movement_params)
  				format.html { redirect_to daily_cashes_path, notice: "Movimiento actualizado con éxito."}
  			else
  				format.html { render :edit}
  			end
  		end
  	end

  	def destroy
  		respond_to do |format|
  			if @daily_cash_movement.destroy
  				format.html { redirect_to daily_cashes_path, notice: "Movimiento eliminado con éxito."}
        else
          format.html { redirect_to daily_cashes_path, alert: "Esta intentando eliminar una apertura de caja cuando existen movimientos posteriores. Esta acción esta prohibida."}
  			end
  		end
  	end

  	private
  		def set_daily_cash_movement
  			@daily_cash_movement = current_user.company.daily_cash_movements.find(params[:id])
  		end

  		def daily_cash_movement_params
  			params.require(:daily_cash_movement).permit(:amount, :associated_document, :movement_type, :payment_type, :flow, :observation, :user_id, :date)
  		end
end
