class Restaurant::MenusController < ApplicationController
  def index
    @restaurant = current_restaurant
    @menu = Menu.new
    @menus = @restaurant.menus.order(id: "DESC").page(params[:page]).per(9)
    @menu_count = Menu.count
  end

  def edit
    @restaurant = current_restaurant
    @menu = Menu.find(params[:id])
    @allergies = Allergy.all
  end

  def update
    @restaurant = current_restaurant
    @menu = Menu.find(params[:id])
    if @menu.update(menu_params)
      redirect_to restaurant_restaurant_menu_path(@restaurant, @menu), notice: 'メニュー情報を編集しました！'
    else
      render :show
    end
  end

  def new
    @restaurant = current_restaurant
    @allergies = Allergy.all
    @menu = Menu.new
  end

  def create
    @menu = current_restaurant.menus.new(menu_params)
    if @menu.save
      redirect_to restaurant_restaurant_menus_path(@menu.id), notice: 'メニューを新規作成しました！'
    else
      @allergies = Allergy.all
      render :new
    end
  end

  def show
    @restaurant = current_restaurant
    @menu = Menu.find(params[:id])
    @menu.image
  end

  def destroy
    @restaurant = current_restaurant
    @menu = current_restaurant.menus.find(params[:id])
    if @menu.destroy
      redirect_to restaurant_restaurant_menus_path(@restaurant), notice: 'メニューを削除しました！'
    end
  end

  private
  def menu_params
    params.require(:menu).permit(:image, :name, :introduction, :price, allergy_ids: [])
  end

end
