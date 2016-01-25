class HomeController < ApplicationController
  around_filter :shopify_session
  layout 'embedded_app'
  helper_method :customer_stats

  def index
    @orders = ShopifyAPI::Order.find(:all, :params => {:limit => 100, :created_at_min => "2016-01-8 00:00"})
    @count = @orders.count
  end

  def vat
    @order = ShopifyAPI::Order.find(params[:order_id])
    @order.note_attributes = {"vat_number" => params[:vat_number]}
    if @order.save
      flash[:success] = "Contribuinte guardado!"
      redirect_to root_path
    else
      flash[:error] = "Erro!"
      redirect_to root_path
    end
  end

  def validate
    @customer = ShopifyAPI::Customer.find(params[:id])
    @customer.tags << params[:address_id]
    if @customer.save
      flash[:success] = "Morada Validada!"
      redirect_to root_path
    else
      flash[:error] = "Erro!"
      redirect_to root_path
    end
  end

  def customer_stats(id)
    @customer = ShopifyAPI::Customer.find(id)
  end

  def tags
    # Fetch orders from the last 30 days. Note that we're fetching a maximum of 250
    # orders, which is the most Shopify allows us to retrieve in one API call. In a
    # more developed solution, you'd need to handle the situation where more than
    # 250 orders had been placed in the last 30 days by fetching multiple pages of
    # orders.
    orders = ShopifyAPI::Order.find(:all, params: { created_at_min: (Time.now - 30.days), limit: 100, status: "any" })

    # Generate a hash mapping product IDs to the total quantity sold. This is done
    # by iterating over every line item in every order, extracting the product ID
    # and quantity from the line item as a Hash, then merging all of those hashes
    # together.
    product_sales = orders.map { |o| o.line_items }.flatten.inject({}) do |product_sales, line_item|
      product_sales.merge(
        Hash[line_item.product_id, line_item.quantity]
      ) { |_, current, additional| current + additional }
    end

    # Sort the list of product sales by quantity in descending order.
    product_sales = Hash[product_sales.sort_by{ |k, v| v }.reverse]

    # Take the first 10 product IDs as our list of most popular products.
    most_popular_products = product_sales.keys.take(10)

    # Fetch all the products in the store. As with orders, we're  limited to 250
    # products here with a single API call. A production version of this script
    # would also support paginating through all products.
    products = ShopifyAPI::Product.find(:all, params: { limit: 10 })

    # Now iterate through every product and add or remove the "Best Seller" tag as
    # needed.
    products.each do |product|
      # Convert tags, which are stored as a comma-separated string, into an array.
      tags = product.tags.split(',').map(&:strip)

      # Add or remove the "Best Seller" tag from the list of product tags depending
      # on whether the product is in the most popular list.
      if most_popular_products.include?(product.id)
        tags << "Best Seller"
      else
        tags.delete("Best Seller")
      end

      # Check to see if a change has been made to the tags, and if so, make the API
      # call to update the product's tags.
      updated_tags = tags.uniq.join(',')
      unless updated_tags == product.tags
        product.tags = updated_tags
        product.save
      end
    end
    redirect_to root_path
  end

end
