require "test_helper"

class LikesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @alice = users(:one)
    @bob   = users(:two)
    @post  = posts(:one)  # owned by alice
    sign_in @bob
  end

  test "liking a post creates a notification for the owner" do
    assert_difference("Notification.count") do
      post post_like_url(@post), as: :turbo_stream
    end
    notif = Notification.last
    assert_equal "post_like", notif.action
    assert_equal @alice,      notif.recipient
    assert_equal @bob,        notif.actor
  end

  test "unliking a post does not create a notification" do
    post post_like_url(@post), as: :turbo_stream  # like
    assert_no_difference("Notification.count") do
      post post_like_url(@post), as: :turbo_stream  # unlike (toggle)
    end
  end

  test "liking your own post does not create a notification" do
    sign_in @alice
    assert_no_difference("Notification.count") do
      post post_like_url(@post), as: :turbo_stream
    end
  end

  test "liking a comment does not create a notification" do
    comment = Comment.create!(body: "great!", post: @post, user: @bob)
    assert_no_difference("Notification.count") do
      post post_comment_like_url(@post, comment), as: :turbo_stream
    end
  end
end
