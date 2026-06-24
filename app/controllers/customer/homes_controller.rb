class Customer::HomesController < ApplicationController
  MANDATORY_ALLERGENS = %w[卵 えび かに そば 落花生 小麦 乳 くるみ].freeze

  def top
    @customer = Customer.new
    @allergies = Allergy.all.sort_by { |a|
      idx = MANDATORY_ALLERGENS.index(a.allergen)
      idx.nil? ? MANDATORY_ALLERGENS.length : idx
    }
    @restaurants = Restaurant.includes(:state, :area, menus: :allergies)
                             .where(is_valid: true)
                             .order(created_at: :desc)
                             .limit(3)
  end

  def about; end
  def terms; end
  def contact; end
end
