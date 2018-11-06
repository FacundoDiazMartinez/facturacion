json.extract! delivery_note, :id, :company_id, :invoice_id, :user_id, :client_id, :active, :state, :created_at, :updated_at
json.url delivery_note_url(delivery_note, format: :json)
