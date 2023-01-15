class Favorite < ApplicationRecord
  belongs_to :customer
  belongs_to :restaurant
  validates :customer_id, uniqueness: { scope: :restaurant_id }
end
