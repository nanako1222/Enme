class CustomerHavingAllergy < ApplicationRecord
  belongs_to :customer
  belongs_to :allergy
end
