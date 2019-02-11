module DailyCashesHelper

	def flow_type flow
		case flow
		when "income"
			return "<div class='text-success'>#{icon('fas', 'arrow-left')} Ingreso</div>".html_safe
		when "expense"
			return "<div class='text-danger'>#{icon('fas', 'arrow-right')} Egreso</div>".html_safe
		when "neutral"
			return "<div class='text-primary'>#{icon('fas', 'exchange-alt')} Neutro</div>".html_safe
		end
	end
end
