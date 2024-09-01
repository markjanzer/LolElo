# frozen_string_literal: true

class SeasonsController < ApplicationController
  def show
    @year = params[:year].to_i
    @league = League.find(params[:league_id])
    @stats = Season::Statistics.new(year: @year, league_id: @league.id).call

    # @page_title = "#{league.name} #{@serie.full_name} Elo Rankings"
    # @page_description = "Explore Elo rankings and performance trends for professional LoL teams in the #{league.name} #{@serie.full_name} series. Compare team strengths and track their progress throughout the season."
  end
end
