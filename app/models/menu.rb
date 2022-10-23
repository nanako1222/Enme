class Menu < ApplicationRecord
  has_one_attached :image
  has_many :menu_having_allergies, dependent: :destroy
  has_many :allergies, through: :menu_having_allergies
  belongs_to :restaurant
end
