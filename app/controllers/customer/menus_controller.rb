class Customer::MenusController < ApplicationController

  def index
    @restaurant = Restaurant.find(params[:restaurant_id])
    # @restaurants = Restaurant.all
    @menu = Menu.new
    @menus = @restaurant.menus.page(params[:page])
    @menu_count = @menus.count
  end

  def show
    @restaurant = current_customer
    @menu = Menu.find(params[:id])
    @state = State.find(@customer.state_id).state
    @area = Area.find(@customer.area_id).area
  end

  private
  def menu_params
    params.require(:menu).permit(:image, :name, :introduction, :price, allergy_ids: [])
  end
end
