class CreateMenuHavingAllergies < ActiveRecord::Migration[6.1]
  def change
    create_table :menu_having_allergies do |t|
      t.references :menu, null: false, foreign_key: true
      t.references :allergy, null: false, foreign_key: true
      t.timestamps
    end
  end
end
