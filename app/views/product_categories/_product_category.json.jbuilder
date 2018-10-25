json.extract! product_category, :id, :name, :iva_aliquot, :active, :company_id, :products_count, :created_at, :updated_at
json.url product_category_url(product_category, format: :json)
