class AddMissingDbConstraints < ActiveRecord::Migration[8.1]
  def up
    change_column_null :posts, :title, false
    change_column_null :users, :email, false
    change_column_null :users, :username, false

    add_check_constraint :rsvps, "status IN ('going', 'maybe', 'not_going')",
                         name: "chk_rsvps_status"
    add_check_constraint :friendships, "status IN ('pending', 'accepted', 'declined')",
                         name: "chk_friendships_status"
    add_check_constraint :community_memberships, "role IN ('member', 'admin')",
                         name: "chk_community_memberships_role"
  end

  def down
    remove_check_constraint :community_memberships, name: "chk_community_memberships_role"
    remove_check_constraint :friendships, name: "chk_friendships_status"
    remove_check_constraint :rsvps, name: "chk_rsvps_status"

    change_column_null :users, :username, true
    change_column_null :users, :email, true
    change_column_null :posts, :title, true
  end
end
