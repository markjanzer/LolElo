# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def panda_score_data
    PandaScore.get_data_for(self)
  end
end
