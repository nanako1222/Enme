class Customer < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :customer_having_allergies, dependent: :destroy
  has_many :allergies, through: :customer_having_allergies, dependent: :destroy
  belongs_to :state
  belongs_to :area

  with_options presence: true do
    validates :last_name, :first_name, :first_name_kana, :last_name_kana, :email,
    :state_id, :area_id, :telephone_number, :password
    validates :telephone_number, format: { with: /\A\d{10,11}\z/ }
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def full_name_kana
    "#{first_name_kana} #{last_name_kana}"
  end

  def active_for_authentication?
    super && (is_valid == true)
  end
  # def inactive_message
  #   return "退会済みのユーザです"
  # end
end
