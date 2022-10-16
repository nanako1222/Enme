class CreateMenus < ActiveRecord::Migration[6.1]
  def change
    create_table :menus do |t|
      t.string :name,               null: false
      t.text :introduction,         null: false
      t.integer :price,             null: false
      t.references :restaurant, null: false, foreign_key: true
      t.timestamps
    end
  end
end
