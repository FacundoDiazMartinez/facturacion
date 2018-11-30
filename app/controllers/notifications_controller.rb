class NotificationsController < ApplicationController

  	def index
  		@notifications = current_user.pull_notifications.order("updated_at DESC").last(10)
  		current_user.pull_notifications.update_all(read_at: Time.now)
  		PrivatePub.publish_to(
				"/facturacion/notifications/#{current_user.id}",
				"$('.notifications').html('0');
				 document.title = 'Desideral.com'"
			)
  	end

end
