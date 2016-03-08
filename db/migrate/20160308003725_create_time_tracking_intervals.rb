class CreateTimeTrackingIntervals < ActiveRecord::Migration
  def change
    create_table :time_intervals do |t|
      t.datetime :started_at
      t.datetime :stopped_at
      t.integer :duration

      t.timestamps null: false
    end
    add_index :time_intervals, :started_at
    add_index :time_intervals, :stopped_at
  end
end
