module UserActivityManager
  class UpdatedSupplierGenerator < ApplicationService
    def initialize(supplier)
      @supplier = supplier
    end

    def call
      activity_for_updated_supplier!
    end

    private

    def activity_for_updated_supplier!
      UserActivity.create(
        user_id: @supplier.updater.id,
        photo: "/images/edit.png",
        title: "El usuario #{@supplier.updater.name} editó un proveedor",
        body: "El día #{I18n.l(Date.today)} el usuario #{@supplier.updater.name} editó al proveedor #{@supplier.name}."
      )
    end
  end
end
