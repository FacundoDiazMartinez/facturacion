class Notification < ApplicationRecord
	belongs_to :sender, class_name: "User", foreign_key: :sender_id, optional: true
	belongs_to :receiver, class_name: "User", foreign_key: :receiver_id, optional: true

	after_create :send_notification


	#PROCESOS
		def send_notification #TODO - UNA VEZ QUE SE AGREGUEN LOS ROLES MODIFICAR ESTO
			PrivatePub.publish_to(
				"/facturacion/notifications/#{receiver_id}",
				"$('.notifications').html('#{receiver.count_notifications}');
				 document.getElementById('notification_sound').play();
				 document.title = '(#{receiver.count_notifications}) - LiteCode.com.ar'"
			)
		end

		def self.create_from_payment payment
		    payment.delayed_job.destroy unless payment.delayed_job.nil?
		    if payment.payment_date > Date.today
			    Notification.delay(run_at: payment.payment_date, payment_id: payment.id).create(
			        title:        "Debe cobrar un pago.",
			        body:         "Se generó una alerta por el cobro de un pago que debería ser acreditado hoy. El tipo de pago es: #{payment.payment_name}",
			        link:         "/invoices/#{payment.invoice_id}.pdf",
			        sender_id:    payment.invoice.user_id,
			        receiver_id:  User.last.id
			    )
			end
		end

		def self.create_for_failed_import invalid, user
		    Notification.create(
		        title:        "Uno o más productos no pudieron importarse.",
		        body:         "Finalizo el proceso de carga de productos, pero uno o más contienen errores. Por favor revise las siguientes filas del archivo que cargo: #{invalid.join(', ')}.",
		        link:         "#",
		        sender_id: 	  0,
		        receiver_id:  user.id
		    )
		end

		def self.create_for_success_import user
		    Notification.create(
		        title:        "¡Finalizó la carga de productos!.",
		        body:         "Finalizo el proceso de carga de productos, ahora puedes verlos en la sección de productos.",
		        link:         "/products",
		        sender_id: 	  0,
		        receiver_id:  user.id
		    )
		end

	#PROCESOS

	#FUNCIONES
		def self.unseen
			where(read_at: nil)
		end
	#FUNCIONES
end
