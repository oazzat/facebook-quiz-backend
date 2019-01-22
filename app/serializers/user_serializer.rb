class UserSerializer < ActiveModel::Serializer
  attributes :name, :email, :current_city, :hometown, :address, :birthday, :quote
  has_many :friends
end
