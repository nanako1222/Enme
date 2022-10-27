class Restaurant::MenusController < ApplicationController
  def index
    @menu = Menu.new
    @menus = Menu.page(params[:page])
    @menu_count = Menu.count
  end

  def edit
    @menu = Menu.find(params[:id])
    @allergies = Allergy.all
  end

  def update
    @menu = Menu.find(params[:id])
binding.pry
    if @menu.update(menu_params)

      params[:menu][:allergies].each do |allergy|
        @menu_having_allergy = MenuHavingAllergy.new(menu_id: @menu.id, allergy_id: allergy)
        @menu_having_allergy.save
      end

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
      params[:menu][:allergies].each do |allergy|
        @menu_having_allergy =MenuHavingAllergy.new(menu_id: @menu.id, allergy_id: allergy)
        @menu_having_allergy.save
    end
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
    params.require(:menu).permit(:image, :name, :introduction, :price, allergies: [])
  end

end
