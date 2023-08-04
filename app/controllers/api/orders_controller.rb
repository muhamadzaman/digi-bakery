class Api::OrdersController < Api::BaseController
  def index
    sleep 1 unless Rails.env.test? # simulate delay in loading
    @orders = Order.all.order(created_at: :desc)
  end

  def update
    @order = Order.find(params[:id])
    @order.update!(fulfilled: true)
  end
end
