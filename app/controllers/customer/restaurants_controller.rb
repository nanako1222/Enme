class Customer::RestaurantsController < ApplicationController
  def show
  end

  def index
    @restaurants = Restaurant.all
  end

  def create
    menu_ids = Menu.joins(:allergies).where(allergis: {id: params[:allergy_id]}).distinct.pluck(:id)
    @restaurant.joins (:menus).where.not(menus:{id:menu_ids})
  end

  def search
    @allergies = Allergy.all
    @customer = Customer.new
  end

  def customer_farm_area
    if request.xhr?
      render partial: 'areas', locals: {ms_pref_id: params[:ms_pref_id]}
    end
  end
end
