class Tribute < ApplicationRecord
  belongs_to :invoice

  def sum_tributes
  	invoice.tributes.sum(:importe).to_f
  end
end
