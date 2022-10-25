class Customer::RestaurantsController < ApplicationController
  before_action :search_demo, only: [:index, :search]
  def show
  end

  def index
    @restaurants = Restaurant.all
  end

  def create
  end

  def search
    @results = @d.result
    # @allergies = Allergy.all
    # @allergy = Allergy.find(params[:id])
  end
  
  private
  def search_demo
    @d = Demo.ransack(params[:q])  # 検索オブジェクトを生成
  end
end
