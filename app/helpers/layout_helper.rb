module LayoutHelper
  def sales_layout_helper(view, &block)
    content_tag :div, class: 'p-4' do
      concat(title("Ventas"))
      concat(sales_nav(view))
      concat(view_wrapper(&block))
    end
  end

  def staff_layout_helper(view, &block)
    content_tag :div, class: 'p-4' do
      concat(title("Personal"))
      concat(staff_nav(view))
      concat(view_wrapper(&block))
    end
  end

  def purchases_layout_helper(view, &block)
    content_tag :div, class: 'p-4' do
      concat(title("Compras"))
      concat(purchases_nav(view))
      concat(view_wrapper(&block))
    end
  end

  def warehouses_layout_helper(view, &block)
    content_tag :div, class: 'p-4' do
      concat(title("Almacén e inventario"))
      concat(warehouses_nav(view))
      concat(view_wrapper(&block))
    end
  end

  def accountant_layout_helper(view, &block)
    content_tag :div, class: 'p-4' do
      concat(title("Contable"))
      concat(accountant_nav(view))
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

  def staff_nav(view)
    render '/staff/_shared/nav.html.erb', active_view: view
  end

  def purchases_nav(view)
    render '/purchases/_shared/nav.html.erb', active_view: view
  end

  def warehouses_nav(view)
    render '/warehouses/_shared/nav.html.erb', active_view: view
  end

  def accountant_nav(view)
    render '/accountant/_shared/nav.html.erb', active_view: view
  end
end
