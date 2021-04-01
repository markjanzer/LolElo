# frozen_string_literal: true

class AddTimeZoneToLeague < ActiveRecord::Migration[6.0]
  def change
    add_column :leagues, :time_zone, :string
  end
end
