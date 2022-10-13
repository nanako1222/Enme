class CustomerHavingAllergy < ApplicationRecord
  has_many :customers, dependent: :destroy
  has_many :allergies, dependent: :destroy
end
