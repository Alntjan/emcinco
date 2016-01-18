class HomeController < ApplicationController
  around_filter :shopify_session
  layout 'embedded_app'

  def index
    @orders = ShopifyAPI::Order.find(:all, :params => {:limit => 100, :created_at_min => "2016-01-8 00:00"})
    @multibancos = []
    @orders.each do |order|
      tposts = order.gateway.eql? "Multibanco"
      @multibancos += tposts if tposts
    end
  end

end
