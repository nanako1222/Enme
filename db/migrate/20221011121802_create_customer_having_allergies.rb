class CreateCustomerHavingAllergies < ActiveRecord::Migration[6.1]
  def change
    create_table :customer_having_allergies do |t|

      t.timestamps
    end
  end
end
