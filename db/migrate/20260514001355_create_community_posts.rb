class CreateCommunityPosts < ActiveRecord::Migration[8.1]
  def change
    create_table :community_posts do |t|
      t.references :post, null: false, foreign_key: true
      t.references :community, null: false, foreign_key: true

      t.timestamps
    end
    add_index :community_posts, [ :post_id, :community_id ], unique: true
  end
end
