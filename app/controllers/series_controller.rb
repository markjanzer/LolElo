class SeriesController < ApplicationController
  def index
    @series = Serie.all
  end

  def show
    @serie = Serie.find(params[:id])
    @chart_data = ChartData.new.call
  end
end
