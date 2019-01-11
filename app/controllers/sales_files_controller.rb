class SalesFilesController < ApplicationController
  def index
  	@sales_files = current_user.company.sales_files.search_by_client(params[:client_name]).search_by_user(params[:user_name]).search_by_state(params[:state]).search_by_date(params[:date]).paginate(per_page: 10, page: params[:page])
  end

  def show
  	@sales_file = current_user.company.sales_files.find(params[:id])
  	@client = @sales_file.client
  end
end
