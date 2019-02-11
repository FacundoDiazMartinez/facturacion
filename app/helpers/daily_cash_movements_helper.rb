module DailyCashMovementsHelper

	def user_with_link movement
		if movement.user_id.blank?
			movement.user_name
		else
			link_to movement.user_name, user_path(movement.user_id)
		end
	end
end
