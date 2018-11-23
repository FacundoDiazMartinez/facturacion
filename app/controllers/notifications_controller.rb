class NotificationsController < ApplicationController

  	def index
  		@notifications = current_user.pull_notifications.last(10)
  	end

end
