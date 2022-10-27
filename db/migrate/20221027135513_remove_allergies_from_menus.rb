class RemoveAllergiesFromMenus < ActiveRecord::Migration[6.1]
  def change
    remove_column :menus, :allergies, :string
  end
end
