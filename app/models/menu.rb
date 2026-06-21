class Menu < ApplicationRecord
  has_one_attached :image
  has_many :menu_having_allergies, dependent: :destroy
  has_many :allergies, through: :menu_having_allergies, dependent: :destroy
  belongs_to :restaurant

  validates :price, :name, presence: true

  def get_image(width, height)
    if image.attached?
      image.url.sub(%r{/upload/}, "/upload/w_#{width},h_#{height},c_fill/")
    else
      ActionController::Base.helpers.asset_path('default-image.jpg')
    end
  end

  def with_tax_price
    (price * 1.1).floor
  end
end
