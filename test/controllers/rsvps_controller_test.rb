require "test_helper"

class RsvpsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @alice    = users(:one)
    @bob      = users(:two)
    @post     = posts(:one)   # owned by alice; bob already has a "going" RSVP (rsvps(:one))
    @new_post = Post.create!(title: "Fresh Meal", user: @alice, meal_date: 1.day.from_now)
    sign_in @bob
  end

  test "new RSVP creates a notification for the post owner" do
    assert_difference("Notification.count") do
      post post_rsvp_url(@new_post), params: { status: "going" }, as: :turbo_stream
    end
    notif = Notification.last
    assert_equal "rsvp",   notif.action
    assert_equal @alice,   notif.recipient
    assert_equal @bob,     notif.actor
  end

  test "changing RSVP status does not create another notification" do
    # bob already has status "going" on @post from the rsvps(:one) fixture
    assert_no_difference("Notification.count") do
      post post_rsvp_url(@post), params: { status: "maybe" }, as: :turbo_stream
    end
  end

  test "un-RSVPing does not create a notification" do
    # sending same status as existing RSVP triggers toggle-off
    assert_no_difference("Notification.count") do
      post post_rsvp_url(@post), params: { status: "going" }, as: :turbo_stream
    end
  end
end
