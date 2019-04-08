module ChequePaymentsHelper

  def cheque_state state
    if state == "Cobrado"
      '<span class="badge badge-success">Cobrado</span>'.html_safe
    else
      '<span class="badge badge-danger">No cobrado</span>'.html_safe
    end
  end
end
