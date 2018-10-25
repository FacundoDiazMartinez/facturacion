json.extract! product, :id, :code, :name, :active, :product_category_id, :list_price, :price, :net_price, :photo, :measurement_unit, :created_at, :updated_at
json.url product_url(product, format: :json)
