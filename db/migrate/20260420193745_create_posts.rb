class CreatePosts < ActiveRecord::Migration[8.1]
  def change
    create_table :posts do |t|
      t.string :title
      t.text :description
      t.datetime :meal_date
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
