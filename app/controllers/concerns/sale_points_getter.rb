module SalePointsGetter
  extend ActiveSupport::Concern

  def get_company_sale_points
    @sale_points = current_company.sale_points
    raise Exceptions::EmptySalePoint if @sale_points.nil?
  end
end
