class FriendSerializer < ActiveModel::Serializer
  attributes :name, :current_city, :hometown, :address, :birthday, :quote, :img
  belongs_to :user
end
