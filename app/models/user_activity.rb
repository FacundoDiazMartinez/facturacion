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
        title: "El usuario #{client.user.name} registró un nuevo cliente",
        body: "El dia #{I18n.l(Date.today)} el usuario #{client.user.name} registró al cliente #{client.name}."
    )
  end

  def self.create_for_updated_client client #Se ejecuta actualiza se crea un cliente
    UserActivity.create(
        user_id: client.user_id,
        photo: "/images/edit.png",
        title: "El usuario #{client.user.name} editó un cliente",
        body: "El dia #{I18n.l(Date.today)} el usuario #{client.user.name} editó al cliente #{client.name}."
    )
  end

  def self.create_for_new_supplier supplier, user #Se ejecuta cuando se crea un proveedor
    UserActivity.create(
        user_id: user.id,
        photo: "/images/supplier.png",
        title: "El usuario #{user.name} registró un nuevo proveedor",
        body: "El dia #{I18n.l(Date.today)} el usuario #{user.name} registró al proveedor #{supplier.name}."
    )
  end

  def self.create_for_updated_supplier supplier, user #Se ejecuta cuando se actualiza un proveedor
    UserActivity.create(
        user_id: user.id,
        photo: "/images/edit.png",
        title: "El usuario #{user.name} editó un proveedor",
        body: "El dia #{I18n.l(Date.today)} el usuario #{user.name} editó al proveedor #{supplier.name}."
    )
  end

  def self.create_for_sended_purchase_order purchase_order #Se ejecuta cuando se envia una ord. de compra al proveedor
    UserActivity.create(
        user_id: purchase_order.user.id,
        photo: "/images/send.png",
        title: "El usuario #{purchase_order.user.name} envio una orden de compra",
        body: "El dia #{I18n.l(Date.today)} el usuario #{purchase_order.user.name} envio al proveedor #{purchase_order.supplier.name} la orden de compra Nº #{purchase_order.number}."
    )
  end

  def self.create_for_purchase_order purchase_order
    UserActivity.create(
        user_id: purchase_order.user.id,
        photo: "/images/edit.png",
        title: "El usuario #{purchase_order.user.name} actualizó el estado de una orden de compra",
        body: "El dia #{I18n.l(Date.today)} el usuario #{purchase_order.user.name} actualizó la orden de compra Nº #{purchase_order.number} a '#{purchase_order.state}'."
    )
  end

  def self.create_for_product_price_history product_price_history #Se crea cuando el precio del producto cambia
    title = "El usuario #{product_price_history.user.name} actualizó precio de"
    activities = product_price_history.user.user_activities.where("DATE(created_at) = ? AND title ILIKE ?", Date.today, "#{title}%") #Busca si existen actividades del mismo tipo
    if activities.count > 1 #si existe actualiza la ultima y la hace mas general
      activities.last.update(
        title: "El usuario #{product_price_history.user.name} actualizó precio de #{activities.count} productos",
        body: "El dia #{I18n.l(Date.today)} el usuario #{product_price_history.user.name} actualizó el precio de #{activities.count} productos."
      )
    else #caso contrario crea una nueva
      UserActivity.create(
          user_id: product_price_history.user.id,
          photo: "/images/price.png",
          title: "El usuario #{product_price_history.user.name} actualizó precio de un producto",
          body: "El dia #{I18n.l(Date.today)} el usuario #{product_price_history.user.name} actualizó el precio de #{product_price_history.product.name} de $#{product_price_history.old_price} a $#{product_price_history.price}."
      )
    end
  end

  def self.create_for_arrival_note arrival_note #Se crea cuando se registra un remito de llegada de mercaderia
    UserActivity.create(
        user_id: arrival_note.user.id,
        photo: "/images/price.png",
        title: "El usuario #{arrival_note.user.name} actualizó precio de un producto",
        body: "El dia #{I18n.l(Date.today)} el usuario #{arrival_note.user.name} registró un remito de la orden de compra Nº#{arrival_note.purchase_order.number} del proveedor #{arrival_note.purchase_order.suppler.name} p."
    )
  end

  def self.create_for_purchase_invoice purchase_invoice #Se crea cuando se carga una factura al sistema de un proveedor
    UserActivity.create(
        user_id: purchase_invoice.user.id,
        photo: "/images/arrival_note.png",
        title: "El usuario #{purchase_invoice.user.name} registró una factura",
        body: "El dia #{I18n.l(Date.today)} el usuario #{purchase_invoice.user.name} registró la factura Nº#{purchase_invoice.number}."
    )
  end
end
