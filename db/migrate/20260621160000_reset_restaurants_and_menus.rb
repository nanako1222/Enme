class ResetRestaurantsAndMenus < ActiveRecord::Migration[6.1]
  def up
    return if Restaurant.count == 0

    ActiveStorage::Attachment.where(record_type: %w[Restaurant Menu]).delete_all
    MenuHavingAllergy.delete_all rescue nil
    Menu.delete_all
    Restaurant.delete_all
  end

  def down
  end
end
