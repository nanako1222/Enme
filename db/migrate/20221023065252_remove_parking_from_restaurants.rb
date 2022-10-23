class RemoveParkingFromRestaurants < ActiveRecord::Migration[6.1]
  def change
    remove_column :restaurants, :parking, :boolean
  end
end
