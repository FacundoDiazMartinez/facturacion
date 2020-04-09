module LayoutHelper
  def sales_layout_helper(view, &block)
    content_tag :div, class: 'p-4' do
      concat(title("Ventas"))
      concat(sales_nav(view))
      concat(view_wrapper(&block))
    end
  end

  def title(texto)
    content_tag :h2, class: 'text-regular' do
			concat(texto.html_safe)
		end
  end

  def view_wrapper(&block)
    content_tag :div, class: 'py-4' do
      capture(&block) if block_given?
    end
  end

  def sales_nav(view)
    render '/sales/_shared/nav.html.erb', active_view: view
  end
end
