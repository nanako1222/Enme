class CustomerHavingAllergy < ApplicationRecord
  belongs_to :customer, dependent: :destroy
  belongs_to :allergy, dependent: :destroy


end
