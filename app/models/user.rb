class User < ApplicationRecord
	belongs_to :company, optional: true
	belongs_to :province, optional: true
	belongs_to :locality, optional: true

  has_many :arrival_notes
  has_many :purchase_invoices
  has_many :pull_notifications, foreign_key: "receiver_id", class_name: "Notification"
  has_many :push_notifications, foreign_key: "sender_id", class_name: "Notification"
  has_many :user_activities
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable, :trackable,
         :recoverable, :rememberable, :validatable

  validate :cant_disapprove_if_has_management_role

  after_create :send_admin_mail, if: Proc.new{ |u| !u.company_id.nil?}
  after_save :set_approved_activity, if: Proc.new{ |u| u.saved_change_to_approved? && !company_id.nil?}

    def set_approved_activity
     UserActivity.create_for_approved_user(self)
    end

    def cant_disapprove_if_has_management_role
      #errors.add(:approve, "No puedes eliminar a un usuario con rol de Gerente.") unless not has_management_role?
    end


  	def set_company company_id
  		update_attribute(:company_id, company_id)
  	end

  	def has_company?
  		not company_id.nil?
  	end

    def has_management_role?
			true
			# if !self.role.blank?
      #   if self.role.name == "Administrador"
      #     return true
      #   end
      # end
      # return false
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

    def send_admin_mail
      AdminMailer.new_user_waiting_for_approval(email).deliver
    end

		def birthday
			if not super.blank?
				I18n.l(super)
			end
	  end

end
