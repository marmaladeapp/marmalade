class CreateTimeTrackingTimers < ActiveRecord::Migration
  def change
    create_table :time_timers do |t|
      t.string :name
      t.text :description
      t.references :context, polymorphic: true, index: true
      t.integer :estimated_time
      t.integer :elapsed_time

      t.timestamps null: false
    end
  end
end
