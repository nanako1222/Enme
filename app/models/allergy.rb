class Allergy < ApplicationRecord
  has_many :customer_having_allergys, dependent: :destroy
  has_many :menu_having_allergys, dependent: :destroy
  has_many :menus, through: :menu_having_allergies
end
