class Restaurant::HomesController < ApplicationController
  def top
    @restaurant = current_restaurant
    @state = State.find(@restaurant.state_id).state
    @area = Area.find(@restaurant.area_id).area
    @restaurant_image = Restaurant.find(params[:id])
    @restaurant_image.image
  end

  def edit
    @restaurant = current_restaurantd
  end

  def update
    @restaurant = current_restaurant
    if @restaurant.update(restaurant_params)
      redirect_to restaurant_path, notice: 'ユーザー情報の変更に成功しました'
    else
      render :edit
    end
  end

  def confirm
    @restaurant = current_restaurant
  end

  def out
    @restaurant = current_restaurant
    @restaurant.update(is_valid: false)
    reset_session
    redirect_to root_path
  end

  private
    def restaurant_params
      params.require(:restaurant).permit(:name, :email, :state_id, :area_id, :telephone_number, :introduction, :news, :home_page,
      :regular_holiday, :parking, :business_hours, :address, :image)
    end
end
