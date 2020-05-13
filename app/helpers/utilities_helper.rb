module UtilitiesHelper
  def number_to_ars number
    number_to_currency( number, unit: "$", format: "%u %n", seperator: ',')
  end

  def number_to_k number
    if number < 1000
      letra = ""
    elsif number < 1000000
      letra = "m"
      number = number * 0.001
    else
      letra = "M"
      number = number * 0.000001
    end
    return "$ #{number.to_i}#{letra}"
  end
end
