class AddDurationMinutesToPosts < ActiveRecord::Migration[8.1]
  def change
    add_column :posts, :duration_minutes, :integer, default: 60, null: false
  end
end
