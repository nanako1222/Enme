class Restaurant < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_one_attached :image
  has_many :menus, dependent: :destroy
  has_many :favorites, dependent: :destroy
  has_many :customers, through: :favorites, dependent: :destroy
  belongs_to :customer, optional: true
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
    if image.attached?
      image.url
    else
      ActionController::Base.helpers.asset_path('default-image.jpg')
    end
  end

  def get_areas
      return  Area.all
  end

  def active_for_authentication?
    super && (is_valid == true)
  end
end