

class Customer::RestaurantsController < ApplicationController

  before_action :set_search_query, only: :index

  def show
    @restaurant = Restaurant.find(params[:id])
    @state = State.find(@restaurant.state_id).state
    @area = Area.find(@restaurant.area_id).area
    @restaurant.image
  end

  def index
    #検索画面のアレルギーにチェックがついていないかつ顧客が持つアレルギーのチェックがないメニューを持つレストランを検索したい
    #1こでもアレルギーが入っているメニューが存在したらそれをはぶいて検索する
    
    menus = if @allergy_ids.blank?
              Menu.all
            else
              Menu.all.reject do |menu|

                menu.allergies.pluck(:id).any? { |allergen| allergen.in?(@allergy_ids) }
              end
            end

    @restaurants = Restaurant.where(id: menus.pluck(:restaurant_id) ,state_id: @state_id, area_id: @area_id )
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
  
  def member_search
    
  end

  def customer_farm_area
    if request.xhr?
      render partial: 'areas', locals: {ms_pref_id: params[:ms_pref_id]}
    end
  end

  private
  # def set_create_query
  #   @allergy_id = params[:allergy_id]
  # end

  # def set_customer_farm_area
  #   @ms_pref_id = params[:ms_pref_id]
  # end

  def set_search_query
    @allergy_ids = params[:allergies].map(&:to_i)
    @state_id = params[:state_id]
    @area_id = params.dig(:customer, :area_id)
  end

end
