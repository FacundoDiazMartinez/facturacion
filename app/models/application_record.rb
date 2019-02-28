class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  # def destroy (hard = nil)
  #   if hard
  #     super
  #   else
  #     update_column(:active, false)
  #     run_callbacks :destroy
  #     freeze
  #   end
  # end
end
