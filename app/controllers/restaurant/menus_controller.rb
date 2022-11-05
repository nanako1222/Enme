class Restaurant::MenusController < ApplicationController
  def index
    @restaurant = current_restaurant
    @menu = Menu.new
    @menus = @restaurant.menus.page(params[:page])
    @menu_count = Menu.count
  end

  def edit
    @menu = Menu.find(params[:id])
    @allergies = Allergy.all
  end

  def update
    @menu = Menu.find(params[:id])
    if @menu.update(menu_params)
      redirect_to restaurant_menus_path(@menu.id), notice: 'Product was successfully updated'
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
      redirect_to restaurant_menus_path(@menu.id), notice: 'Product was successfully created'
    else
      @allergies = Allergy.all
      render :new
    end
  end

  def show
    @menu = Menu.find(params[:id])
    @menu.image
  end

  def destroy
  end

  private
  def menu_params
    params.require(:menu).permit(:image, :name, :introduction, :price, allergy_ids: [])
  end

end
