class Customer::FavoritesController < ApplicationController
  before_action :set_restaurant, only: [:create, :destroy]
  def create
    @favorite = Favorite.new(customer_id: current_customer.id,  restaurant_id: @restaurant.id)
    @favorite.save!

  end

  def destroy
    @favorite = Favorite.find_by(customer_id: current_customer.id, restaurant_id: @restaurant.id)
    @favorite.destroy!
  end

  def index
    @customer = current_customer
    @favorite = Favorite.new
    @favorites = @customer.favorites.order(id: "DESC").page(params[:page]).per(9)
    @favorites_count = @customer.favorites.count
  end

  private
  def set_restaurant
    @restaurant = Restaurant.find(params[:restaurant_id])
  end
end
