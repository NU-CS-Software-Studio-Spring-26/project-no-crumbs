require "test_helper"

class PostTest < ActiveSupport::TestCase
  test "can create a post with valid attributes" do
    user = users(:one)
    post = Post.new(title: "Taco Tuesday", description: "Making tacos for everyone", meal_date: Time.now, user: user)
    assert post.save
  end

  test "post has a title" do
    post = posts(:one)
    assert_equal "Homemade Lasagna Night", post.title
  end

  test "post has a description" do
    post = posts(:one)
    assert_not_nil post.description
  end

  test "post has a meal_date" do
    post = posts(:one)
    assert_not_nil post.meal_date
  end

  test "post belongs to a user" do
    post = posts(:one)
    assert_respond_to post, :user
    assert_instance_of User, post.user
  end

  test "post requires a user" do
    post = Post.new(title: "No User Post", description: "desc", meal_date: Time.now)
    assert_not post.save
  end
end
