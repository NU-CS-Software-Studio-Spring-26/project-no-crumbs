class AddDietaryRestrictionsToUsersAndPosts < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :dietary_restrictions, :string, array: true, default: []
    add_column :posts, :dietary_restrictions, :string, array: true, default: []
  end
end
