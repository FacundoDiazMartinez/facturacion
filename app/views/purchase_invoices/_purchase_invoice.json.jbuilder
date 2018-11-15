json.extract! purchase_invoice, :id, :company_id, :user_id, :arrival_note_id, :number, :supplier_id, :state, :cbte_tipo, :net_amount, :iva_amount, :imp_op_ex, :total, :created_at, :updated_at
json.url purchase_invoice_url(purchase_invoice, format: :json)
