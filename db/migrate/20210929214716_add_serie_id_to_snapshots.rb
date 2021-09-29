class AddSerieIdToSnapshots < ActiveRecord::Migration[6.0]
  def change
    add_reference :snapshots, :serie, index: true, foreign_key: true
  end
end
