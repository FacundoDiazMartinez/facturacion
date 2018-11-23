module UsersHelper

	def change_state_to_user user
		if user.approved
			link_to	"#{icon('fas', 'sign-out-alt')} Expulsar".html_safe, disapprove_user_path(user.id), method: :patch
		else
			link_to	"#{icon('fas', 'sign-in-alt')} Aceptar".html_safe, approve_user_path(user.id), method: :patch
		end
	end
end
