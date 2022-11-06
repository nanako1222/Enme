class Allergy < ApplicationRecord
  has_many :customer_having_allergies, dependent: :destroy
  has_many :customers, through: :customer_having_allergies, dependent: :destroy
  has_many :menu_having_allergies, dependent: :destroy
  has_many :menus, through: :menu_having_allergies, dependent: :destroy
end
