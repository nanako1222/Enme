class Admin::HomesController < ApplicationController
  before_action :authenticate_admin!
  before_action :restrict_demo_mode, only: [:edit_password, :update_password]

  def top
    @restaurant = Restaurant.new
    @restaurants = Restaurant.all.order(id: "DESC").page(params[:page]).per(10)
  end

  def edit_password; end

  def update_password
    if current_admin.update_with_password(admin_password_params)
      bypass_sign_in(current_admin)
      redirect_to admin_path, notice: 'パスワードを変更しました'
    else
      render :edit_password
    end
  end

  private

  def restaurant_params
    params.require(:restaurant).permit(:name, :email, :state_id, :area_id, :telephone_number, :introduction, :news, :home_page,
      :regular_holiday, :parking, :business_hours, :address, :image)
  end

  def admin_password_params
    params.require(:admin).permit(:current_password, :password, :password_confirmation)
  end
end
