class Menu < ApplicationRecord
  has_one_attached :image
  has_many :menu_having_allergys, dependent: :destroy
  belongs_to :restaurant
end
