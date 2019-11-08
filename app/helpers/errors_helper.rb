module ErrorsHelper
  def flash_error
		messages = flash.map{|name, msg| content_tag :li, msg if msg.is_a?(String)}.join
		html = <<-HTML
		<div class="alert alert-danger alert-dismissible fade show" role="alert">
			#{messages}
			<button type="button" class="close" data-dismiss="alert" aria-label="Close">
    			<span aria-hidden="true">&times;</span>
  			</button>
		</div>
		HTML
    return html.html_safe
	end

	def error_explanation object=nil
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

  def error_for_modal_js message, type #danger info success
		html = "<div class='alert alert-#{type} alert-dismissible' role='alert'> <button type='button' class='close' data-dismiss='alert' aria-label='Close'><span aria-hidden='true'>&times;</span></button> #{message} </div>"
		return html.html_safe
	end
end
