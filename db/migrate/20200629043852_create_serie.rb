# frozen_string_literal: true

class CreateSerie < ActiveRecord::Migration[6.0]
  def change
    create_table :series do |t|
      t.integer :external_id
      t.datetime :begin_at
      t.string :full_name
      t.integer :year
    end

    add_reference :matches, :serie, index: true
  end
end
