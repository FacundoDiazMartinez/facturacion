module ApplicationHelper

	def button_new_helper path
		link_to "#{icon('fas', 'plus')}".html_safe, path, class: 'btn btn-success btn-floated'
	end

	def button_edit_helper path
		link_to "#{icon('fas', 'edit')}".html_safe, path, class: 'btn btn-success btn-floated'
	end

	def button_new_modal_helper path, target
		target ||= "myModal"
		link_to "#{icon('fas', 'plus')}".html_safe, path, class: 'btn btn-success btn-floated', data: { toggle: 'modal', target: "##{target}" }, remote: true
	end

	def save_button(options = {})
		button_tag "#{icon('fas', 'save')} Guardar".html_safe,{ type: 'submit', class: 'btn btn-primary', id: 'save_btn', data: {disable_with: "#{icon('fas', 'sync')} Cargando..."}}.merge(options)
	end

	def save_button_danger
		button_tag "#{icon('fas', 'save')} Guardar".html_safe, type: 'submit', class: 'btn btn-danger', id: 'save_btn', data: {disable_with: "#{icon('fas', 'sync')} Cargando..."}
	end

	def save_button_lock
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
			"<span class='text-success'> #{icon('fas', icon)} </span>".html_safe
		else
			icon = 'minus-square'
			"<span class='text-danger'> #{icon('fas', icon)} </span>".html_safe
		end
	end

	def title_helper text
		content_tag :div, class: 'd-flex justify-content-between flex-wrap flex-md-nowrap align-items-center mb-3' do
			concat(full_title(text))
		end
	end

	def full_title(titulo)
		content_tag :h1, class: 'h2' do
			concat(titulo.html_safe)
		end
	end
end
