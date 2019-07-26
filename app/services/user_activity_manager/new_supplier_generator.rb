module UserActivityManager
  class NewSupplierGenerator < ApplicationService
    def initialize(supplier)
      @supplier = supplier
    end

    def call
      activity_for_new_supplier!
    end

    private

    def activity_for_new_supplier!
      UserActivity.create(
        user_id: @supplier.created_by,
        photo: "/images/supplier.png",
        title: "El usuario #{@supplier.creator.name} registró un nuevo proveedor",
        body: "El día #{I18n.l(Date.today)} el usuario #{@supplier.creator.name} registró al proveedor #{@supplier.name}."
      )
    end
  end
end
