class ClearImageAttachmentsAgain < ActiveRecord::Migration[6.1]
  def up
    ActiveStorage::Attachment.where(record_type: %w[Restaurant Menu]).delete_all
  end

  def down
  end
end
