json.extract! receipt, :id, :invoice_id, :client_id, :active, :total, :date, :observation, :company_id, :created_at, :updated_at
json.url receipt_url(receipt, format: :json)
