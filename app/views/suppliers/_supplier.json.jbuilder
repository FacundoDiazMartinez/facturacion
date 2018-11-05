json.extract! supplier, :id, :name, :document_type, :document_number, :phone, :mobile_phone, :address, :email, :cbu, :active, :company_id, :created_at, :updated_at
json.url supplier_url(supplier, format: :json)
