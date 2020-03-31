module PurchaseOrderManager
  class MailSender < ApplicationService
    attr_accessor :purchase_order
    attr_reader :email_to

    def initialize(purchase_order, email_to)
      @purchase_order = purchase_order
      @email_to = email_to
    end

    def call
      if verifica_email?
        envia_correo
        orden_de_compra_enviada!
      end
      return purchase_order
    end

    private

    def verifica_email?
      if email_to.blank?
        purchase_order.errors.add(:email, "Debe ingresar una dirección de correo para enviar la órden de compra.")
        return false
      end
      true
    end

    def envia_correo
      PurchaseOrderMailer.delay.send_mail(purchase_order, email_to)
    end

    def orden_de_compra_enviada!
      purchase_order.enviado!
    end
  end
end
