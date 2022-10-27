class AddallergiesToMenus < ActiveRecord::Migration[6.1]
  def change
    add_column :menus, :allergies, :string ,array: true
  end
end
