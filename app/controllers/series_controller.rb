# frozen_string_literal: true

class SeriesController < ApplicationController
  def index
    years = Serie.distinct.order(year: :desc).pluck(:year)
    leagues = League.all.sort_by { |league| League::LEAGUE_ORDER[league.name] }

    series_data = Serie.includes(:league)
      .where(year: years)
      .order(begin_at: :desc)
      .group_by { |serie| [serie.year, serie.league_id]}

    @series_by_year_and_league = years.each_with_object({}) do |year, years_hash|
      years_hash[year] = leagues.each_with_object({}) do |league, leagues_hash|
        league_series = series_data[[year, league.id]] || []
        leagues_hash[league.name] = {
          id: league.id,
          series: league_series.map { |serie| { name: serie.full_name, url: "series/#{serie.id}" } }
        }
      end
    end
  end
  
  def show
    @serie = Serie.find(params[:id])
    league = @serie.league
    @previous_serie = league.series.where("begin_at < ?", @serie.begin_at)
      .order(begin_at: :desc)
      .first
    @next_serie = league.series.where("begin_at > ?", @serie.begin_at)
      .order(begin_at: :asc)
      .first
    @chart_data = ChartData.new(@serie).call

    @page_title = "#{league.name} #{@serie.full_name} Elo Rankings"
    @page_description = "Explore Elo rankings and performance trends for professional LoL teams in the #{league.name} #{@serie.full_name} series. Compare team strengths and track their progress throughout the season."
  end
end
