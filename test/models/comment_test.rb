require "test_helper"

class CommentTest < ActiveSupport::TestCase
  setup do
    @alice = users(:one)
    @bob   = users(:two)
    @post  = posts(:one)
    @charlie = User.create!(username: "charlie", email: "charlie@example.com", password: "password123")
  end

  test "valid comment" do
    assert Comment.new(post: @post, user: @bob, body: "Can't wait!").valid?
  end

  test "invalid without body" do
    assert_not Comment.new(post: @post, user: @bob, body: nil).valid?
  end

  test "invalid with empty body" do
    assert_not Comment.new(post: @post, user: @bob, body: "  ").valid?
  end

  test "invalid when body exceeds 500 characters" do
    assert_not Comment.new(post: @post, user: @bob, body: "a" * 501).valid?
  end

  test "valid at exactly 500 characters" do
    assert Comment.new(post: @post, user: @bob, body: "a" * 500).valid?
  end

  test "invalid without post" do
    assert_not Comment.new(post: nil, user: @bob, body: "hi").valid?
  end

  test "invalid without user" do
    assert_not Comment.new(post: @post, user: nil, body: "hi").valid?
  end

  test "multiple comments per post allowed" do
    Comment.create!(post: @post, user: @bob, body: "First!")
    assert Comment.new(post: @post, user: @charlie, body: "Second!").valid?
  end

  test "same user can comment multiple times" do
    Comment.create!(post: @post, user: @bob, body: "First!")
    assert Comment.new(post: @post, user: @bob, body: "Again!").valid?
  end

  test "post has_many comments" do
    assert_respond_to @post, :comments
  end

  test "user has_many comments" do
    assert_respond_to @bob, :comments
  end

  test "comments destroyed when post is destroyed" do
    comment = Comment.create!(post: @post, user: @bob, body: "See you there!")
    @post.destroy
    assert_nil Comment.find_by(id: comment.id)
  end

  test "comments destroyed when user is destroyed" do
    comment = Comment.create!(post: @post, user: @charlie, body: "Excited!")
    assert_difference "Comment.count", -1 do
      @charlie.destroy
    end
    assert_nil Comment.find_by(id: comment.id)
  end
end
