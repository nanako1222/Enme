class Allergy < ApplicationRecord
  has_many :customer_having_allergys, dependent: :destroy
  has_many :menu_having_allergys, dependent: :destroy

  # enum payment_method: { nothing: 0, egg: 1, shrimp: 2, crab: 3, buckwheat: 4, peanuts: 5, wheat: 6, milk: 7,
  # abalone: 8, squid: 9, salmon_roe: 10, orange: 11, kiwi: 12, beef: 13, walnut: 14, salmon: 15, apple: 16,
  # mackerel: 17, soy: 18, chicken: 19, banana: 20, pork: 21, matsutake_mushroom: 22, peach: 23, yam: 24, gelatin: 25,
  # sesame: 26, cashew: 27, almond: 28}

end
