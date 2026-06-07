require "test_helper"

class RsvpsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @alice       = users(:one)
    @bob         = users(:two)
    @post        = posts(:one)   # owned by alice; archived (past meal_date)
    @future_post = Post.create!(title: "Fresh Meal", user: @alice, meal_date: 1.day.from_now)
    # bob has a pre-existing RSVP on @future_post for destroy/toggle tests
    @bob_rsvp    = Rsvp.create!(post: @future_post, user: @bob, status: "going")
    sign_in @bob
  end

  # --- create: notification behavior ---

  test "new RSVP creates a notification for the post owner" do
    fresh = Post.create!(title: "Notification Meal", user: @alice, meal_date: 2.days.from_now)
    assert_difference("Notification.count") do
      post post_rsvp_url(fresh), params: { status: "going" }, as: :turbo_stream
    end
    notif = Notification.last
    assert_equal "rsvp",   notif.action
    assert_equal @alice,   notif.recipient
    assert_equal @bob,     notif.actor
  end

  test "changing RSVP status does not create another notification" do
    # @bob_rsvp already exists on @future_post (created in setup, which triggered no notification)
    # updating its status should not create a new notification
    assert_no_difference("Notification.count") do
      post post_rsvp_url(@future_post), params: { status: "maybe" }, as: :turbo_stream
    end
  end

  test "toggling off (same status) removes the RSVP record" do
    assert_difference("Rsvp.count", -1) do
      post post_rsvp_url(@future_post), params: { status: "going" }, as: :turbo_stream
    end
  end

  test "toggling off does not create a notification" do
    assert_no_difference("Notification.count") do
      post post_rsvp_url(@future_post), params: { status: "going" }, as: :turbo_stream
    end
  end

  test "create responds with turbo_stream" do
    fresh = Post.create!(title: "Stream Meal", user: @alice, meal_date: 3.days.from_now)
    post post_rsvp_url(fresh), params: { status: "going" }, as: :turbo_stream
    assert_response :success
    assert_equal "text/vnd.turbo-stream.html", response.media_type
  end

  # --- authorize_rsvp!: host cannot RSVP own meal ---

  test "host is redirected when attempting to RSVP their own meal" do
    sign_in @alice
    post post_rsvp_url(@future_post), params: { status: "going" }, as: :turbo_stream
    assert_redirected_to @future_post
    assert_equal "You can't RSVP to your own meal.", flash[:alert]
  end

  test "host RSVP attempt does not create an RSVP record" do
    sign_in @alice
    assert_no_difference("Rsvp.count") do
      post post_rsvp_url(@future_post), params: { status: "going" }, as: :turbo_stream
    end
  end

  # --- authorize_rsvp!: archived meal ---

  test "user is redirected when attempting to RSVP an archived meal" do
    archived = Post.new(title: "Old Meal", user: @alice, meal_date: 2.days.ago)
    archived.save(validate: false)
    post post_rsvp_url(archived), params: { status: "going" }, as: :turbo_stream
    assert_redirected_to archived
    assert_equal "This meal has already passed.", flash[:alert]
  end

  test "RSVP attempt on archived meal does not create a record" do
    archived = Post.new(title: "Old Meal 2", user: @alice, meal_date: 2.days.ago)
    archived.save(validate: false)
    assert_no_difference("Rsvp.count") do
      post post_rsvp_url(archived), params: { status: "going" }, as: :turbo_stream
    end
  end

  # --- authentication ---

  test "unauthenticated user is redirected to sign in on create" do
    sign_out :user
    post post_rsvp_url(@future_post), params: { status: "going" }, as: :turbo_stream
    assert_redirected_to new_user_session_path
  end

  # --- destroy ---

  test "destroy removes an existing RSVP" do
    assert_difference("Rsvp.count", -1) do
      delete post_rsvp_url(@future_post), as: :turbo_stream
    end
  end

  test "destroy when no RSVP exists does not raise" do
    no_rsvp_post = Post.create!(title: "No RSVP Meal", user: @alice, meal_date: 5.days.from_now)
    assert_nothing_raised do
      delete post_rsvp_url(no_rsvp_post), as: :turbo_stream
    end
  end

  test "destroy responds with turbo_stream" do
    delete post_rsvp_url(@future_post), as: :turbo_stream
    assert_response :success
    assert_equal "text/vnd.turbo-stream.html", response.media_type
  end

  # --- export ---

  test "export returns a calendar attachment" do
    get export_rsvps_url
    assert_response :success
    assert response.headers["Content-Type"].include?("text/calendar")
    assert_includes response.headers["Content-Disposition"], "no-crumbs-meals.ics"
  end

  test "export ics includes going RSVPs with meal_date" do
    get export_rsvps_url
    assert_includes response.body, "[GOING]"
    assert_includes response.body, @future_post.title
  end

  test "export ics includes maybe RSVPs" do
    maybe_post = Post.create!(title: "Maybe Meal", user: @alice, meal_date: 3.days.from_now)
    Rsvp.create!(post: maybe_post, user: @bob, status: "maybe")
    get export_rsvps_url
    assert_includes response.body, "[MAYBE]"
    assert_includes response.body, maybe_post.title
  end

  test "export excludes not_going RSVPs" do
    declined_post = Post.create!(title: "Declined Meal", user: @alice, meal_date: 4.days.from_now)
    Rsvp.create!(post: declined_post, user: @bob, status: "not_going")
    get export_rsvps_url
    assert_not_includes response.body, "Declined Meal"
  end

  test "export excludes RSVPs for posts without a meal_date" do
    no_date_post = Post.create!(title: "Floating Meal", user: @alice, meal_date: nil)
    Rsvp.create!(post: no_date_post, user: @bob, status: "going")
    get export_rsvps_url
    assert_not_includes response.body, "Floating Meal"
  end

  test "unauthenticated user is redirected from export" do
    sign_out :user
    get export_rsvps_url
    assert_redirected_to new_user_session_path
  end

  test "export uses duration_minutes for DTEND" do
    @future_post.update!(duration_minutes: 90)
    get export_rsvps_url
    expected_end = (@future_post.meal_date + 90.minutes).strftime("%Y%m%dT%H%M%S")
    assert_includes response.body, expected_end
  end

  test "export falls back to 60 minutes when duration_minutes is default" do
    get export_rsvps_url
    expected_end = (@future_post.meal_date + 60.minutes).strftime("%Y%m%dT%H%M%S")
    assert_includes response.body, expected_end
  end
end
