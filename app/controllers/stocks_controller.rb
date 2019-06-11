class StocksController < ApplicationController
	before_action :set_product
	before_action :set_stock

  	def edit
  	end

  	def update
  		respond_to do |format|
	  		if @stock.update(stock_params)
	  			format.html {redirect_to @product, notice: "Stock actualizado correctamente."}
	  		else
	  			format.html {render :edit}
	  		end
	  	end
  	end

  	def destroy
    	@stock.destroy
    	respond_to do |format|
      		format.html { redirect_to stocks_path, notice: 'Eliminado correctamente.' }
      		format.json { head :no_content }
    	end
  	end

  	private
	  	def set_product
	  		@product = current_user.company.products.find(params[:product_id])
	  	end

	  	def set_stock
	  		@stock = @product.stocks.find(params[:id])
	  	end

	  	def stock_params
	  		params.require(:stock).permit(:id, :depot_id, :quantity, :_destroy)
	  	end
end
