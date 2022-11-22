class Menu < ApplicationRecord
  has_one_attached :image
  has_many :menu_having_allergies, dependent: :destroy
  has_many :allergies, through: :menu_having_allergies, dependent: :destroy
  belongs_to :restaurant

  validates :price, :name, presence: true

  def get_image(width, height)
    unless image.attached?
      file_path = Rails.root.join('app/assets/images/default-image.jpg')
      image.attach(io: File.open(file_path), filename: 'default-image.jpg', content_type: 'image/jpeg')
    end
    image.variant(resize_to_limit: [width, height]).processed
  end

  def with_tax_price
    (price * 1.1).floor
  end
end
