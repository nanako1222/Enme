class AddStateIdToCustomers < ActiveRecord::Migration[6.1]
  def change
    add_column :customers, :state_id, :integer
  end
end
