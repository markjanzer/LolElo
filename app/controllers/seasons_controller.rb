# frozen_string_literal: true

class SeasonsController < ApplicationController
  def show
    @year = params[:year].to_i
    @league = League.find(params[:league_id])
    @stats = Season::Statistics.new(year: @year, league_id: @league.id).call

    @page_title = "Statistics for the #{@league.name} #{@year} Season"
    @page_description = "Explore statistics for the #{@league.name} #{@year} season. See who was the most unpredictable, what was the biggest upset, who had the biggest downfall and more."
  end
end
