class ApplicationController < ActionController::Base
  def index
  end

  def chart_data
    render json: ChartData.new.call
  end
end
