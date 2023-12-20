class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.string :name, null: false, limit: 255
      t.string :password, null: false, limit: 255
      t.string :email, null: false, limit: 255
      t.references :user_group, null: false, foreign_key: true

      t.timestamps
    end
  end
end
