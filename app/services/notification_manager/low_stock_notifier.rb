module NotificationManager
  class LowStockNotifier < ApplicationService
    def initialize(product)
      @product = product
    end
    def call
      notify_low_stock
    end

    private

    def notify_low_stock
      @product.company.users.each do |user|
		    Notification.create(
	        title:        "¡Se debe reponer stock!",
	        body:         "La disponibilidad del producto #{@product.name} se encuentra por debajo del límite establecido.",
	        link: 				"/products/#{@product.id}",
	        sender_id: 	  0,
	        receiver_id:  user.id
		    )
			end
    end
  end
end
