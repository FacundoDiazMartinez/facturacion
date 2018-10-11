class Company < ApplicationRecord
	has_many :sale_points, dependent: :destroy

	accepts_nested_attributes_for :sale_points, allow_destroy: true, reject_if: :all_blank
	mount_uploader :logo, ImageUploader

	CONCEPTOS = ["Productos", "Servicios", "Productos y Servicios"]
end
