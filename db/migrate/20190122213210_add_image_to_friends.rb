class AddImageToFriends < ActiveRecord::Migration[5.2]
  def change
    add_column :friends, :img, :string
  end
end
