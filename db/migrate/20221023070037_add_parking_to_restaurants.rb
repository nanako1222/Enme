class AddParkingToRestaurants < ActiveRecord::Migration[6.1]
  def change
    add_column :restaurants, :parking, :string
  end
end
