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

  	private
	  	def set_product
	  		@product = current_user.company.products.find(params[:product_id])
	  	end

	  	def set_stock
	  		@stock = @product.stocks.find(params[:id])
	  	end

	  	def stock_params
	  		params.require(:stock).permit(:quantity)
	  	end
end