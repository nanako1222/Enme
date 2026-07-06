class Admin < ApplicationRecord
  include PasswordComplexity

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
end
