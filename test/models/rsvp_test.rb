require "test_helper"

class RsvpTest < ActiveSupport::TestCase
  setup do
    @alice = users(:one)
    @bob   = users(:two)
    @post  = posts(:one)
    @charlie = User.create!(username: "charlie", email: "charlie@example.com", password: "password123")
  end

  test "valid with going status" do
    assert Rsvp.new(post: @post, user: @charlie, status: "going").valid?
  end

  test "valid with maybe status" do
    assert Rsvp.new(post: @post, user: @charlie, status: "maybe").valid?
  end

  test "valid with not_going status" do
    assert Rsvp.new(post: @post, user: @charlie, status: "not_going").valid?
  end

  test "invalid with unknown status" do
    assert_not Rsvp.new(post: @post, user: @charlie, status: "attending").valid?
  end

  test "invalid without status" do
    assert_not Rsvp.new(post: @post, user: @charlie, status: nil).valid?
  end

  test "host cannot RSVP to their own meal" do
    rsvp = Rsvp.new(post: @post, user: @alice, status: "going")
    assert_not rsvp.valid?
    assert_includes rsvp.errors[:base], "You can't RSVP to your own meal"
  end

  test "duplicate user+post pair is invalid" do
    Rsvp.create!(post: @post, user: @charlie, status: "going")
    assert_not Rsvp.new(post: @post, user: @charlie, status: "maybe").valid?
  end

  test "different users can RSVP to the same meal" do
    # @bob already has an RSVP via fixture; charlie has not yet RSVPed
    assert Rsvp.new(post: @post, user: @charlie, status: "going").valid?
  end

  test "same user can RSVP to different meals" do
    other_post = Post.create!(title: "BBQ Night", description: "burgers", meal_date: 2.days.from_now, user: @alice)
    Rsvp.create!(post: @post, user: @charlie, status: "going")
    assert Rsvp.new(post: other_post, user: @charlie, status: "going").valid?
  end

  test "belongs to post" do
    assert_equal @post, rsvps(:one).post
  end

  test "belongs to user" do
    assert_equal @bob, rsvps(:one).user
  end

  test "post has_many rsvps" do
    assert_respond_to @post, :rsvps
  end

  test "user has_many rsvps" do
    assert_respond_to @alice, :rsvps
  end

  test "rsvps destroyed when post is destroyed" do
    rsvp = Rsvp.create!(post: @post, user: @charlie, status: "going")
    count_before = Rsvp.count
    @post.destroy
    assert_nil Rsvp.find_by(id: rsvp.id)
    assert Rsvp.count < count_before
  end

  test "rsvps destroyed when user is destroyed" do
    rsvp = Rsvp.create!(post: @post, user: @charlie, status: "going")
    assert_difference "Rsvp.count", -1 do
      @charlie.destroy
    end
    assert_nil Rsvp.find_by(id: rsvp.id)
  end

  test "post archived? returns true when meal_date is more than 36 hours ago" do
    old_post = Post.create!(title: "Old", description: "d", meal_date: 37.hours.ago, user: @alice)
    assert old_post.archived?
  end

  test "post archived? returns false for future meal" do
    future_post = Post.create!(title: "Future", description: "d", meal_date: 2.days.from_now, user: @alice)
    assert_not future_post.archived?
  end

  test "post archived? returns false when meal_date is nil" do
    no_date_post = Post.create!(title: "No Date", description: "d", meal_date: nil, user: @alice)
    assert_not no_date_post.archived?
  end

  # DB constraint tests — bypass model validations with update_column / save(validate: false)
  test "database enforces status CHECK constraint on update" do
    rsvp = Rsvp.create!(post: @post, user: @charlie, status: "going")
    assert_raises(ActiveRecord::StatementInvalid) { rsvp.update_column(:status, "attending") }
  end

  test "database enforces status CHECK constraint on insert" do
    rsvp = Rsvp.new(post: @post, user: @charlie, status: "attending")
    assert_raises(ActiveRecord::StatementInvalid) { rsvp.save(validate: false) }
  end
end
