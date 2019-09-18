module DepotsGetter
  extend ActiveSupport::Concern

  def get_company_depots
    @company_depots = current_company.depots
    raise Exceptions::EmptyDepot if @company_depots.nil?
  end
end
