class Customer::MenusController < ApplicationController

  def index
    @restaurant = Restaurant.find(params[:restaurant_id])
    # @restaurants = Restaurant.all
    @menu = Menu.new
    @menus = @restaurant.menus.page(params[:page]).per(7)
    @menu_count = @menus.count
  end

  def show
    @restaurant = Restaurant.find(params[:restaurant_id])
    @menu = Menu.find(params[:id])
  end

  private
  def menu_params
    params.require(:menu).permit(:image, :name, :introduction, :price, allergy_ids: [])
  end
end
