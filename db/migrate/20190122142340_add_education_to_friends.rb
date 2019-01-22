class AddEducationToFriends < ActiveRecord::Migration[5.2]
  def change
    add_column :friends, :education, :string
  end
end
