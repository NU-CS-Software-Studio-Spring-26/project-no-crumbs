require "test_helper"

class CommentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @alice = users(:one)
    @bob   = users(:two)
    @post  = posts(:one)  # owned by alice
    sign_in @bob
  end

  test "creating a comment notifies the post owner" do
    assert_difference("Notification.count") do
      post post_comments_url(@post), params: { comment: { body: "Looks delicious!" } }, as: :turbo_stream
    end
    notif = Notification.last
    assert_equal "comment",  notif.action
    assert_equal @alice,     notif.recipient
    assert_equal @bob,       notif.actor
    assert_equal Comment.last, notif.notifiable
  end

  test "commenting on your own post does not create a notification" do
    sign_in @alice
    assert_no_difference("Notification.count") do
      post post_comments_url(@post), params: { comment: { body: "My own post!" } }, as: :turbo_stream
    end
  end

  test "invalid comment does not create a notification" do
    assert_no_difference("Notification.count") do
      post post_comments_url(@post), params: { comment: { body: "" } }
    end
  end

  test "unauthenticated user cannot comment" do
    sign_out :user
    post post_comments_url(@post), params: { comment: { body: "sneaky" } }
    assert_redirected_to new_user_session_path
  end
end
