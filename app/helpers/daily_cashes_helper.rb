module DailyCashesHelper

	def flow_type flow
		case flow
		when "income"
			return "<div class='text-success'>#{icon('fas', 'arrow-down')} Ingreso</div>".html_safe
		when "expense"
			return "<div class='text-danger'>#{icon('fas', 'arrow-up')} Egreso</div>".html_safe
		end
	end
end
