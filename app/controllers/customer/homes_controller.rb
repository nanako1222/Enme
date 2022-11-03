class Customer::HomesController < ApplicationController
  def top
    @restaurant = current_restaurant
  end

  def about
  end
end
