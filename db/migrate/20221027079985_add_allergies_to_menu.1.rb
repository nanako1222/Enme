class AddallergiesToMenus < ActiveRecord::Migration[6.1]
  def change
    add_column :menus, :allergies, :text ,array: true
    serialize :allergies,Array
  end
end
