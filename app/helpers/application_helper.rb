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

	def paginate resource, param_name = nil
		@resource = resource
		content_tag :div, style: 'width: 100%' do
			concat(will_paginate_helper(param_name))
			concat(javascript_paginate_helper)
		end
	end
	def will_paginate_helper param_name
		will_paginate @resource, list_classes: %w(pagination justify-content-center), :page_links => true,
		 							 :inner_window => 1,
		  							 :outer_window => 1,
		  							 :param_name => param_name || "page",
		   							 :previous_label => '← Anterior',
		    						 :next_label => 'Siguiente →',
		     						 renderer: WillPaginate::ActionView::BootstrapLinkRenderer
	end

	def javascript_paginate_helper
		javascript_tag("$('ul.pagination a').click(function(){$.getScript(this.href); return false; });")
	end

	def boolean_to_icon bool
		if bool
			icon = 'check-square'
			"<div style='color: green;'> #{icon('fas', icon)} </div>".html_safe
		else
			icon = 'minus-square'
			"<div style='color: red;'> #{icon('fas', icon)} </div>".html_safe
		end
	end

	def title icon, text, path=nil, path_title=nil
		@icon = icon
		@text = text
		@path = path
		content_tag :div, class: 'title-container' do
			concat(full_title)
			concat(hr_line)
		end
	end

	def full_title
		content_tag :h1, class: 'd-flex mb-2' do
			concat(left_title)
			concat(right_title)
		end
		
	end

	def left_title
		content_tag :div, class: 'p-2' do
			concat(icon('fas', 'user'))
			concat(@text)
		end
	end

	def right_title
		content_tag :div, class: 'ml-auto p-2' do
			concat(link_to "#{icon('fas', 'chevron-left')} Volver".html_safe, :back, class: 'btn btn-danger')
			concat(link_to "#{icon('fas', 'plus')} #{path_title}".html_safe, @path, class: 'btn btn-primary') unless @path.nil?
		end
	end

	def hr_line
		content_tag :hr
	end
end
