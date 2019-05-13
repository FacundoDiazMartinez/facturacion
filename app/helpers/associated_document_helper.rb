module AssociatedDocumentHelper

  def assoc_doc_state_label_helper state
    case state

      # ORDEN DE COMPRA
      when 'Pendiente'
        label_span('badge badge-pill badge-info', 'Pendiente')
      when 'Aprobado'
        label_span('badge badge-pill badge-info', 'Aprobado')
      when 'Finalizada'
        label_span('badge badge-pill badge-success', 'Finalizada')

      # FACTURA
      when "Pagado"
        label_span('badge badge-pill badge-warning', 'Pagado')
      when "Confirmado"
        label_span('badge badge-pill badge-success', 'Confirmado')
      when "Anulado"
        label_span('badge badge-pill badge-dark', 'Anulado')
      when "Anulado parcialmente"
        label_span('badge badge-pill badge-dark', 'Anulado Parcialmente')

      # RECIBO
      when 'Finalizado'
	     	label_span('badge badge-pill badge-success', 'Finalizado')
    end
  end

  def assoc_doc_fecha_helper doc
    case doc.type_of_model
    when "invoice"
      doc.cbte_fch
    else
      doc.created_at
    end
  end


end
