class Admin::RestaurantsController < ApplicationController
  before_action :authenticate_admin!
  def index
    @restaurant = Restaurant.new
    @restaurants = Restaurant.page(params[:page])
  end

  def show
    @restaurant = Restaurant.find(params[:id])
  end

  def edit
    @restaurant = Restaurant.find(params[:id])
  end

  def update
    @restaurant = Restaurant.find(params[:id])
    if @restaurant.update(restaurant_params)
      redirect_to admin_restaurant_path, notice: 'Customer was successfully updated'
    else
      render :edit
    end
  end

  private
  def restaurant_params
    params.require(:restaurant).permit(:name, :email, :state_id, :area_id, :telephone_number, :introduction, :news, :home_page,
      :regular_holiday, :parking, :business_hours, :address, :image)
  end
end
