class Restaurant < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_one_attached :image
  has_many :menus, dependent: :destroy
  belongs_to :state
  belongs_to :area

  with_options presence: true do
    validates :name, :email, :state_id, :area_id,
              :regular_holiday, :business_hours, :address
              with_options on: :create do
                validates :password
                validates :password_confirmation
              end
    validates :telephone_number, format: { with: /\A\d{10,11}\z/ }
  end

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