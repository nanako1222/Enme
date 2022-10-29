class CustomerHavingAllergy < ApplicationRecord
  belongs_to :customer, dependent: :destroy
  belongs_to :allergy, dependent: :destroy
    has_many :allergies, through: :menu_having_allergies

end
