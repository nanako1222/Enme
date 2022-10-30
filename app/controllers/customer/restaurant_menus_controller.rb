class Customer::RestaurantMenusController < ApplicationController
    before_action :authenticate_restaurant!
  def index
  end

  def show
    @restaurant = current_customer
    @state = State.find(@customer.state_id).state
    @area = Area.find(@customer.area_id).area
  end
end
