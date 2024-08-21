# frozen_string_literal: true

class SeriesController < ApplicationController
  def index
    years = Serie.all.pluck(:year).uniq.sort.reverse
    result = {}
    years.each do |year|
      year_data = {}
      League.all.each do |league|
        league_series = league.series.where(year: year).order(begin_at: :desc).map do |serie|
          {
            name: serie.full_name,
            url: "series/#{serie.id}",
          }
        end
        year_data[league.name] = league_series
      end
      result[year] = year_data
    end

    @years = result
  end
  
  def show
    @serie = Serie.find(params[:id])
    @chart_data = ChartData.new(@serie).call
  end
end
