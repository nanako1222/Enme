class State < ApplicationRecord
has_many :customers, dependent: :destroy
has_many :areas, dependent: :destroy
has_many :restaurants, dependent: :destroy
end
