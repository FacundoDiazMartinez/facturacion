class Notification < ApplicationRecord
	belongs_to :sender, class_name: "User", foreign_key: :sender_id
	belongs_to :receiver, class_name: "User", foreign_key: :receiver_id, optional: true

	after_create :send_notification


	#PROCESOS
		def send_notification #TODO - UNA VEZ QUE SE AGREGUEN LOS ROLES MODIFICAR ESTO
			PrivatePub.publish_to(
				"/facturacion/notifications/#{sender_id}",
				"$('.notifications').html('#{sender.count_notifications}');
				 document.getElementById('notification_sound').play();
				 document.title = '(#{sender.count_notifications}) - Desideral.com'"
			)
		end

		def self.create_from_payment payment
		    payment.delayed_job.destroy unless payment.delayed_job.nil?

		    Notification.delay(run_at: payment.payment_date, payment_id: payment.id).create(
		        title:        "Debe cobrar un pago.",
		        body:         "Se generó una alerta por el cobro de un pago que debería ser acreditado hoy.",
		        link:         "/invoices/#{payment.invoice_id}",
		        sender_id:    payment.invoice.user_id,
		        receiver_id:  User.last.id
		    )
		end

	#PROCESOS

	#FUNCIONES
		def self.unseen
			where(read_at: nil)
		end
	#FUNCIONES
end
