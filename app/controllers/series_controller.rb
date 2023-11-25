# frozen_string_literal: true

class SeriesController < ApplicationController
  def index
    @leagues = League.all.includes(:series)
  end
  
  def show
    @serie = Serie.find(params[:id])
    @chart_data = ChartData.new(@serie).call
  end
end
