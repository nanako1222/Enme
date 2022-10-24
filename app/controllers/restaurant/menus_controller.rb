class Restaurant::MenusController < ApplicationController
  def index
    @menu = Menu.new
    @menus = Menu.page(params[:page])
  end

  def edit
    @menu = Menu.find(params[:id])
  end

  def update
    @menu = Menu.find(params[:id])
    if @item.update(menu_params)
      redirect_to restaurant_menus_path(@menu.id), notice: 'Product was successfully updated'
    else
      render :show
    end
  end

  def new
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
    params.require(:menu).permit(:image, :name, :introduction, :price, :allergen)
  end
end
