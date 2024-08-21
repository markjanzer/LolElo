# frozen_string_literal: true

class SeriesController < ApplicationController
  def index
    @series_by_year_and_league = Serie
      .includes(:league)
      .order(year: :desc, begin_at: :desc)
      .group_by(&:year)
      .transform_values do |series|
        series.group_by(&:league)
              .transform_keys(&:name)
              .transform_values do |league_series|
                league_series.map do |serie|
                  {
                    name: serie.full_name,
                    url: "series/#{serie.id}"
                  }
                end
              end
              .sort_by { |league_name, _| League::LEAGUE_ORDER[league_name] }
      end
  end
  
  def show
    @serie = Serie.find(params[:id])
    @chart_data = ChartData.new(@serie).call
  end
end
