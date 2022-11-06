class MenuHavingAllergy < ApplicationRecord
  belongs_to :menu
  belongs_to :allergy
end
