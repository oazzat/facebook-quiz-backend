module Api
  module V1
class FriendsController < ApplicationController

  def index
    render json: Friend.all
  end

end

end
end
