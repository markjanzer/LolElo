class ApplicationController < ActionController::Base
  def index
    @chart_data = chart_data
  end

  private 

  def chart_data
    ChartData.new.call
  end
end
