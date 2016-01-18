class HomeController < ApplicationController
  around_filter :shopify_session
  layout 'embedded_app'

  def index
    @products = ShopifyAPI::Order.find(:all, :params => {:limit => 10})
  end

end
