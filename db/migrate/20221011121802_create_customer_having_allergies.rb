class CreateCustomerHavingAllergies < ActiveRecord::Migration[6.1]
  def change
    create_table :customer_having_allergies do |t|
      t.references :allergy, null: false, foreign_key: true
      t.references :customer, null: false, foreign_key: true
      t.timestamps
    end
  end
end
