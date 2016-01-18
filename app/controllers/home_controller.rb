class HomeController < ApplicationController
  around_filter :shopify_session
  layout 'embedded_app'

  def index
    @orders = ShopifyAPI::Order.find(:all, :params => {:limit => 100})
    @multibanco = @orders.where(:email => "oliveiracatarino88@gmail.com")
  end

end
