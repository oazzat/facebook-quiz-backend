class ScoreSerializer < ActiveModel::Serializer
  attributes :id, :correct, :total
end
