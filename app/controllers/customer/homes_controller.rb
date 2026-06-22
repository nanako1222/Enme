class Customer::HomesController < ApplicationController
  def top
    @customer = Customer.new
    @allergies = Allergy.all
    @restaurants = Restaurant.includes(:state, :area, menus: :allergies)
                             .where(is_valid: true)
                             .order(created_at: :desc)
                             .limit(6)
  end

  def about
  end
end
