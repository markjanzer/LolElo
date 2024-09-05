class StaticPagesController < ApplicationController
  def what_is_elo
    @page_title = "What is Elo?"
    @page_description = "Learn about the Elo rating system and how it is used to rank and compare the skill levels of players and teams in competitive games like League of Legends."
  end
end
