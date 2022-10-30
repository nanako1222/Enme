

class Customer::RestaurantsController < ApplicationController
  
  before_action :set_search_query, only: :index
  
  def show
  end

  def index
    #indexアクション内で検索画面のチェックボックスで検索を行いたい.
    #検索画面のアレルギーにチェックがついていないかつ顧客が持つアレルギーのチェックがないメニューを持つレストランを検索したい
    #1こでもアレルギーが入っているメニューが存在したらそれをはぶいて検索する
  
    menus = if @allergy_ids.blank?
              Menu.all
            else
              Menu.all.reject do |menu|
      
                menu.allergies.pluck(:allergen).any? { |allergen| allergen.in?(@allergy_ids) }
              end
            end
    
    @restaurants = Restaurant.where(id: menus.pluck(:restaurant_id) ,state_id: @state_id, area_id: @area_id )
    
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
  
  private
  

  def set_search_query
    @allergy_ids = params[:allergies]
    @state_id = params[:state_id]
    @area_id = params.dig(:customer, :area_id)
  end

end
