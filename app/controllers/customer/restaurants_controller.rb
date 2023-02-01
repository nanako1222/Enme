

class Customer::RestaurantsController < ApplicationController

  before_action :set_search_query, only: :index

  def show
    @restaurant = Restaurant.find(params[:id])
    @state = State.find(@restaurant.state_id).state
    @area = Area.find(@restaurant.area_id).area
    @restaurant.image
  end

  def index
    #byebug
    #検索画面のアレルギーにチェックがついていないかつ顧客が持つアレルギーのチェックがないメニューを持つレストランを検索
    #1こでもアレルギーが入っているメニューが存在したらそれをはぶいて検索する
    #ただし顧客のアレルギーを一つでも持っていないメニューがある飲食店は表示させる
    menus = if @allergy_ids.blank?
              Menu.all
            else
              Menu.all.reject do |menu|
                menu.allergies.pluck(:id).any? { |allergen| allergen.in?(@allergy_ids) }
              end
            end

    if @state_id && @area_id
      @restaurants = Restaurant.where(id: menus.pluck(:restaurant_id), state_id: @state_id, area_id: @area_id )
    elsif @state_id
      @restaurants = Restaurant.where(id: menus.pluck(:restaurant_id), state_id: @state_id)
    elsif @area_id
      @restaurants = Restaurant.where(id: menus.pluck(:restaurant_id), area_id: @area_id)
    else
      @restaurants = Restaurant.all
    end
    @restaurant_count = @restaurants.count
    @restaurants = @restaurants.order(id: "DESC").page(params[:page]).per(9)
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


  # def set_customer_farm_area
  #   @ms_pref_id = params[:ms_pref_id]
  # end

  def set_search_query
    @allergy_ids = params.dig(:customer, :allergies)&.map(&:to_i) || []
    @state_id = params[:state_id]
    @area_id = params.dig(:customer, :area_id)
  end

end

#https://2fa50ee19e8141c384c19facfdbf4b5d.vfs.cloud9.ap-northeast-1.amazonaws.com
#/restaurants?allergies[]=2&allergies[]=3&state_id=1&customer[area_id]=1&commit=%E6%A4%9C%E7%B4%A2