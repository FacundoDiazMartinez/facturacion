class UserActivity < ApplicationRecord
  belongs_to :user

  def self.create_for_confirmed_invoice invoice  #Se ejecuta cuando una factura se confirma
  	UserActivity.create(
        user_id: invoice.user.id,
        photo: "/images/invoice.png",
        title: "Emitió un comprobante",
        body: "El dia #{I18n.l(Date.today)} generó y confirmó un comprobante tipo #{invoice.tipo} destinado al cliente #{invoice.client.name}, por un monto de $#{invoice.total.tound(2)}."
    )
  end

  def self.create_for_approved_user user #Se ejecuta cuando se aprueba un usuario
  	UserActivity.create(
        user_id: user.id,
        photo: "/images/log-in.png",
        title: "El usuario fue aprobado. Ahora pertenece y tiene acceso a #{user.company.name}",
        body: "El dia #{I18n.l(Date.today)} se le dio acceso a #{user.name} para hacer uso de las funciones del sistema de #{user.company.name}."
    )
  end

  def self.create_for_new_client client #Se ejecuta cuando se crea un cliente
    UserActivity.create(
        user_id: client.user_id,
        photo: "/images/person.png",
        title: "El usuario #{client.user.name} registro un nuevo cliente",
        body: "El dia #{I18n.l(Date.today)} el usuario #{client.user.name} registro al cliente #{client.name}."
    )
  end

  def self.create_for_updated_client client #Se ejecuta cuando se crea un cliente
    UserActivity.create(
        user_id: client.user_id,
        photo: "/images/edit.png",
        title: "El usuario #{client.user.name} editó un cliente",
        body: "El dia #{I18n.l(Date.today)} el usuario #{client.user.name} editó al cliente #{client.name}."
    )
  end
end
