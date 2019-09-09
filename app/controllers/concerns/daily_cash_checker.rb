module DailyCashChecker
  extend ActiveSupport::Concern

  def check_daily_cash
    daily = current_company.daily_cashes.abierta.find_by_date(Date.today)
    raise Exceptions::DailyCashClose if daily.nil?
  end
end
