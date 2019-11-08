module CompanyManager
  class Creator < ApplicationService

    def initialize(company, user)
      @company = company
      @user    = user
    end

    def call
      set_company_to_user
      set_company_admin
    end

    private

    def set_company_to_user
      @user.update_columns(company_id: @company.id, admin: true)
    end

    def set_company_admin
			admin_role = Role.where(company_id: @company.id, name: "Administrador").first_or_create
			UserRole.where(role_id: admin_role.id, user_id: @user.id).first_or_create
    end
  end
end
