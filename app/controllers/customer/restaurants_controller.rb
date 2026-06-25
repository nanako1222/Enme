

class Customer::RestaurantsController < ApplicationController

  before_action :set_search_query, only: :index

  def show
    @restaurant = Restaurant.find(params[:id])
    @state = State.find(@restaurant.state_id).state
    @area = Area.find(@restaurant.area_id).area
    @restaurant.image
  end

  def index
    restaurants = Restaurant.where(is_valid: true)
    restaurants = restaurants.where(state_id: @state_id) if @state_id.present?
    restaurants = restaurants.where(area_id: @area_id) if @area_id.present?

    unless @allergy_ids.blank?
      unsafe_menu_ids = Menu.joins(:allergies).where(allergies: { id: @allergy_ids }).select(:id)
      safe_restaurant_ids = Menu.where.not(id: unsafe_menu_ids).pluck(:restaurant_id).uniq
      restaurants = restaurants.where(id: safe_restaurant_ids)
    end

    @restaurant_count = restaurants.count
    @restaurants = restaurants.includes(:state, :area, menus: :allergies)
                              .order(id: "DESC").page(params[:page]).per(9)

    @selected_allergies   = Allergy.where(id: @allergy_ids) if @allergy_ids.present?
    @selected_state_name  = State.find(@state_id).state if @state_id.present?
    @selected_area_name   = Area.find(@area_id).area if @area_id.present?
  end

  def create
    @allergy_id = params[:allergy_id]
    menu_ids = Menu.joins(:allergies).where(allergis: {id: params[:allergy_id]}).distinct.pluck(:id)
    # menu_ids = Menu.joins(:allergies).where(allergis: {id: @allergy_id}).distinct.pluck(:id)
    @restaurant.joins (:menus).where.not(menus:{id:menu_ids})
  end

  def search
    @allergies = Allergy.all
    @customer = Customer.new
    @selected_allergy_ids = params.dig(:customer, :allergies)&.map(&:to_i) || []
    @selected_state_id    = params.dig(:customer, :state_id).presence
    @selected_area_id     = params.dig(:customer, :area_id).presence
  end

  def simple_search
    @customer = current_customer
    @allergies = Allergy.all
  end

  def customer_farm_area
    if request.xhr?
      render partial: 'areas', locals: {ms_pref_id: params[:ms_pref_id]}
    end
  end
  
  def favorite
    @favorite_restaurants = current_customer.favorite_restaurants.includes(:customer).order(created_at: :desc)
  end

  private

  def set_search_query
    @allergy_ids = params.dig(:customer, :allergies)&.map(&:to_i) || []
    @state_id = params.dig(:customer, :state_id)
    @area_id = params.dig(:customer, :area_id)
  end

end

#https://2fa50ee19e8141c384c19facfdbf4b5d.vfs.cloud9.ap-northeast-1.amazonaws.com
#/restaurants?allergies[]=2&allergies[]=3&state_id=1&customer[area_id]=1&commit=%E6%A4%9C%E7%B4%A2