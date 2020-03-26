module Deleteable
	extend ActiveSupport::Concern

	def destroy(mode = :soft)
    if mode == :hard
      	super()
    else
	    self.update_column(:active, false)
	    self.run_callbacks :destroy
	    self.freeze
    end
	end
end
