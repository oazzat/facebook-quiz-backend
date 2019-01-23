module Api
  module V1

class ScoresController < ApplicationController

  def index
    render json: Score.all
  end

end

end
end 
