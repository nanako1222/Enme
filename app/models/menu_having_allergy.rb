class MenuHavingAllergy < ApplicationRecord
  belongs_to :menu, dependent: :destroy
  belongs_to :allergy, dependent: :destroy
end
