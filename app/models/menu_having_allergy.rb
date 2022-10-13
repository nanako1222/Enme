class MenuHavingAllergy < ApplicationRecord
  has_many :menus, dependent: :destroy
  has_many :allergies, dependent: :destroy
end
