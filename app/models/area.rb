class Area < ApplicationRecord
  has_many :restaurants, dependent: :destroy
  belongs_to :state
end
