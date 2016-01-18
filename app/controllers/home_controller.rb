class HomeController < ApplicationController
  around_filter :shopify_session
  layout 'embedded_app'

  def index
    @orders = ShopifyAPI::Order.find(:all, :params => {:limit => 10})
    @mb = ShopifyAPI::Order.find(:all, :params => { :gateway => "Multibanco" })
  end

end
