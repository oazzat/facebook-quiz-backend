class ScoreSerializer < ActiveModel::Serializer
  attributes :id, :correct, :total, :user_id
end
