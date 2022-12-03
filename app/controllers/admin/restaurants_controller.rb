class Admin::RestaurantsController < ApplicationController
  before_action :authenticate_admin!
  def index
    @restaurant = Restaurant.new
    @restaurants = Restaurant.all.order(id: "DESC").page(params[:page]).per(10)
  end

  def show
    @restaurant = Restaurant.find(params[:id])
    @state = State.find(@restaurant.state_id).state
    @area = Area.find(@restaurant.area_id).area
  end

  def edit
    @restaurant = Restaurant.find(params[:id])
    @area = Area.where(state_id: @restaurant.state_id)
  end

  def update
    @restaurant = Restaurant.find(params[:id])
    if @restaurant.update(restaurant_params)
      redirect_to admin_restaurant_path, notice: '飲食店情報を編集しました！'
    else
      flash.now[:alert] =  '登録に失敗しました'
      render :edit
    end
  end

  private
  def restaurant_params
    params.require(:restaurant).permit(:name, :email, :state_id, :area_id, :telephone_number, :introduction, :news, :home_page,
      :regular_holiday, :parking, :is_valid, :business_hours, :address, :image)
  end
end
