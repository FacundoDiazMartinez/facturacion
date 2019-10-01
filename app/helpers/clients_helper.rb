module ClientsHelper
  def client_enabled_badge enabled
    if enabled
      "<span class='badge badge-pill badge-success client-enabled-badge'>Habilitado</span>".html_safe
    else
      "<span class='badge badge-pill badge-danger client-enabled-badge'>Inhabilitado</span>".html_safe
    end
  end

  def client_valid_for_account_badge valid_for_account
    if valid_for_account
      "<span class='badge badge-pill badge-success client-account-badge'>Cta. Cte.</span>".html_safe
    else
      "<span class='badge badge-pill badge-danger client-account-badge'>Cta. Cte.</span>".html_safe
    end
  end
end
