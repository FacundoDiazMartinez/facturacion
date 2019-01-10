class SaleFileController < ApplicationController
  def index
  	@sale_fields = current_user.company.sale_fields.search_by_user(params[:user_name]).search_by_state(params[:state]).search_by_date(:date).paginate(per_page: 10, page: params[:page])
  end

  def show
  end
end
