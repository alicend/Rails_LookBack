class CreateTasks < ActiveRecord::Migration[7.0]
  def change
    create_table :tasks do |t|
      t.string :task, null: false, limit: 255
      t.string :description, null: false, limit: 255
      t.references :creator, null: false, foreign_key: { to_table: :users }
      t.references :category, null: false, foreign_key: true
      t.integer :status, null: false
      t.references :responsible, null: false, foreign_key: { to_table: :users }
      t.integer :estimate
      t.datetime :start_date

      t.timestamps
    end
  end
end
