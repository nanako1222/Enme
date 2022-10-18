class AddStateIdToRestaurants < ActiveRecord::Migration[6.1]
  def change
    add_column :restaurants, :state_id, :integer
  end
end
