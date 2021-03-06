class User < ApplicationRecord
	belongs_to :company, optional: true
	belongs_to :province, optional: true
	belongs_to :locality, optional: true

	has_many :user_roles
  has_many :roles, through: :user_roles
	has_many :permissions, through: :user_roles
  has_many :arrival_notes
	has_many :advertisements
  has_many :purchase_invoices
  has_many :pull_notifications, foreign_key: "receiver_id", class_name: "Notification"
  has_many :push_notifications, foreign_key: "sender_id", class_name: "Notification"
  has_many :user_activities
  has_many :client
  has_many :commissioners
  has_many :daily_cash_movements
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable, :trackable,
         :recoverable, :rememberable, :validatable

  validate :cant_disapprove_if_has_management_role
  before_validation :set_admin_if_owner

	default_scope { where(active: true) }

  accepts_nested_attributes_for :user_roles, reject_if: :all_blank, allow_destroy: true

  after_create :send_admin_mail, if: Proc.new{ |u| u.has_company?}
  after_save :set_approved_activity, if: Proc.new{ |u| u.saved_change_to_approved? && u.has_company?}

  #FILTROS DE BUSQUEDA
    def self.search_by_name name
      if !name.nil?
        where("LOWER(first_name ||' ' || last_name) LIKE LOWER(?)", "%#{name}%")
      else
        all
      end
    end

    def self.search_by_document document_number
      if !document_number.blank?
        where("dni::text ILIKE ?", "#{document_number}%")
      else
        all
      end
    end

    def self.search_by_state state
      if state == "Aprobados"
        where(approved: true).or(where(admin: true))
      elsif state == "No aprobados"
        where(approved: false, admin: false)
      else
        all
      end
    end
  #FILTROS DE BUSQUEDA

    def set_approved_activity
     UserActivity.create_for_approved_user(self)
    end

    def cant_disapprove_if_has_management_role
      #errors.add(:approve, "No puedes eliminar a un usuario con rol de Gerente.") unless not has_management_role?
    end

  	def has_company?
  		not company_id.nil?
  	end

    def has_management_role?
			return self.admin || self.roles.map(&:name).include?("Administrador")
    end

    def has_purchase_management_role?
      return true
    end

    def has_stock_management_role?
      return true
    end

		def has_advertisement_management_role?
			return true
		end

		def role_label
			if self.has_management_role?
				"Administrador"
			else
				self.roles.blank? ? "Sin acceso" : self.roles.map{|a| a.name}.join(', ')
			end
		end

    def name
      "#{last_name}, #{first_name}"
    end

    def count_notifications #TODO - UNA VEZ QUE SE AGREGUEN LOS ROLES MODIFICAR ESTO
      pull_notifications.unseen.count
    end

    def avatar
      read_attribute("avatar") || "/images/default_user.png"
    end

    def approved?
      has_management_role? ? true : read_attribute("approved")
    end

    def active_for_authentication?
      super && approved?
    end

    def inactive_message
      approved? ? super : :not_approved
    end

    def self.send_reset_password_instructions(attributes={})
      recoverable = find_or_initialize_with_errors(reset_password_keys, attributes, :not_found)
      if !recoverable.approved?
        recoverable.errors[:base] << I18n.t("devise.failure.not_approved")
      elsif recoverable.persisted?
        recoverable.send_reset_password_instructions
      end
      recoverable
    end

		def destroy
			self.update_column(:approved, false)
      self.update_column(:active, false)
      run_callbacks :destroy
      freeze
    end

    def send_admin_mail
      AdminMailer.new_user_waiting_for_approval(email).deliver
    end

    def set_admin_if_owner
      if self.company_id.nil?
        self.admin = true
				self.approved = true
      end
    end

end
