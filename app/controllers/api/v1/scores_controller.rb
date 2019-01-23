module Api
  module V1

class ScoresController < ApplicationController

  def index
    render json: Score.all
  end

  def update
    @score = Score.find(params[:id])
    # byebug
    @score.total = params[:attributes][:total]
    @score.correct = params[:attributes][:correct]
    @score.save()
    render json: @score
  end

end

end
end
