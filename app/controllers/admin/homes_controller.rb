class Admin::HomesController < ApplicationController
  before_action :authenticate_admin!
  def top
    @restaurant = Restaurant.new
    @restaurants = Restaurant.all.order(id: "DESC").page(params[:page]).per(10)
  end

  private
  def restaurant_params
    params.require(:restaurant).permit(:name, :email, :state_id, :area_id, :telephone_number, :introduction, :news, :home_page,
      :regular_holiday, :parking, :business_hours, :address, :image)
  end
end
