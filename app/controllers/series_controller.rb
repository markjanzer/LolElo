# frozen_string_literal: true

class SeriesController < ApplicationController
  def show
    @league = League.find(params[:league_id])
    @serie = @league.series.find(params[:id])
    @chart_data = ChartData.new(@serie).call
  end
end
