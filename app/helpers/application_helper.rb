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

	def save_button
		button_tag "#{icon('fas', 'save')} Guardar".html_safe, type: 'submit', class: 'btn btn-primary', id: 'save_btn'
	end

	def back_button icon = nil
		given_icon ||= 'chevron-left'
		link_to "#{icon('fas', given_icon)} Volver".html_safe, :back, :class => 'btn btn-danger', :style => 'color:#fff'
	end

end
