class AddAreaIdToCustomers < ActiveRecord::Migration[6.1]
  def change
    add_column :customers, :area_id, :integer
  end
end
