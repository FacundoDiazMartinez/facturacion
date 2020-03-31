module UtilitiesHelper
  def number_to_ars number
    number_to_currency( number, unit: "$", format: "%u %n", seperator: ',')
  end
end
