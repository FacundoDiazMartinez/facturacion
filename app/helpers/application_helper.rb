module ApplicationHelper

	def error_explanation object
		@object = object
		if not object.nil?
			content_tag :div do
				concat(errors_flash)
			end
		end
	end

	def errors_flash
		if @object.errors.any?
			content_tag :div, class: "alert alert-danger", role:"alert" do
		      	concat(error_explanation_loop)
			end
		end
	end

	def error_explanation_loop
		content_tag :ul do
        	@object.errors.each do |attr, message|
	        	concat(li_message(attr, message))
	        end
	    end
	end

	def li_message attr, message
		content_tag :li do
    		"#{message}"
  		end
	end

end
