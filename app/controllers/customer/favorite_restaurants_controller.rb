class Customer::FavoriteRestaurantsController < ApplicationController
  def favorite
    @favorite_restaurants = current_customer.favorite_restaurants.includes(:customer).order(created_at: :desc)
  end
end
