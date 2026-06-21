class ClearRestaurantsForReseed < ActiveRecord::Migration[6.1]
  def up
    return if Restaurant.count == 0

    # ActiveStorage添付を削除（Cloudinary側の孤立ファイルはデモなので許容）
    ActiveStorage::Attachment.where(record_type: %w[Restaurant Menu]).delete_all

    # メニュー関連→メニュー→レストランの順に削除
    MenuHavingAllergy.delete_all rescue nil
    Menu.delete_all
    Restaurant.delete_all
  end

  def down
  end
end
