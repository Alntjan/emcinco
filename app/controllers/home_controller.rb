class HomeController < ApplicationController
  around_filter :shopify_session
  layout 'embedded_app'

  def index
    @orders = ShopifyAPI::Order.find(:all, :params => {:limit => 10})
    @mb = ["Multibanco"].collect {|gateway| Shopify::Order.find(gateway)}
  end

end
