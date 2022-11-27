class Restaurant < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_one_attached :image
  has_many :menus, dependent: :destroy
  belongs_to :state
  belongs_to :area

  validates :name, :email, :state_id, :area_id, :telephone_number,:regular_holiday, :business_hours, :address, presence: true

  def get_image(width, height)
    unless image.attached?
      file_path = Rails.root.join('app/assets/images/default-image.jpg')
      image.attach(io: File.open(file_path), filename: 'default-image.jpg', content_type: 'image/jpeg')
    end
    image.variant(resize_to_limit: [width, height]).processed
  end

  def get_areas
      return  Area.all
  end

  def active_for_authentication?
    super && (is_valid == true)
  end
end