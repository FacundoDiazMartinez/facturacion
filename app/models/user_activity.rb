class UserActivity < ApplicationRecord
  belongs_to :user

  def self.create_for_confirmed_invoice invoice  #Se ejecuta cuando una factura se confirma
  	UserActivity.create(
        user_id: invoice.user.id,
        photo: "/images/log-in.png",
        title: "Emitió un comprobante",
        body: "El dia #{I18n.l(Date.today)} generó y confirmó un comprobante tipo #{invoice.tipo} destinado al cliente #{invoice.client.name}, por un monto de $#{invoice.total.tound(2)}."
    )
  end

  def create_for_approved_user user
  	UserActivity.create(
        user_id: user.id,
        photo: "/images/log-in.png",
        title: "El usuario fue aprobado. Ahora pertenece y tiene acceso a #{user.company.name}",
        body: "El dia #{I18n.l(Date.today)} se le dio acceso a #{user.name} para hacer uso de las funciones del sistema de #{user.company.name}."
    )
  end
end
