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

  test "active scope excludes posts older than 36 hours" do
    user = users(:one)
    old_post = user.posts.create!(title: "Old Meal", description: "desc", meal_date: 2.days.ago)
    assert_not_includes Post.active, old_post
  end

  test "active scope includes posts within 36 hours" do
    user = users(:one)
    recent_post = user.posts.create!(title: "Recent Meal", description: "desc", meal_date: 1.hour.from_now)
    assert_includes Post.active, recent_post
  end

  test "archived scope includes posts older than 36 hours" do
    user = users(:one)
    old_post = user.posts.create!(title: "Old Meal", description: "desc", meal_date: 2.days.ago)
    assert_includes Post.archived, old_post
  end

  test "archived scope excludes recent posts" do
    user = users(:one)
    recent_post = user.posts.create!(title: "Future Meal", description: "desc", meal_date: 1.day.from_now)
    assert_not_includes Post.archived, recent_post
  end

  test "post can be created without a meal_date" do
    user = users(:one)
    post = Post.new(title: "Someday Meal", description: "No date yet", user: user)
    assert post.save
  end
end
