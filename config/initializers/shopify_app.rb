ShopifyApp.configure do |config|
  config.api_key = "a05f5b1d8c29038ac3ff492a151207e9"
  config.secret = "5359700d60f5d04ffbfdb562cb0375a9"
  config.scope = "read_orders, read_products, write_products, write_orders, write_customers"
  config.embedded_app = false
  config.routes = false
end
