class CreateCommunityMemberships < ActiveRecord::Migration[8.1]
  def change
    create_table :community_memberships do |t|
      t.bigint :user_id, null: false
      t.bigint :community_id, null: false
      t.string :role, null: false, default: "member"

      t.timestamps
    end
    add_index :community_memberships, :user_id
    add_index :community_memberships, :community_id
    add_index :community_memberships, [ :user_id, :community_id ], unique: true
    add_foreign_key :community_memberships, :users
    add_foreign_key :community_memberships, :communities
  end
end
