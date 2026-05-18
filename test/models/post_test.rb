require "test_helper"

class PostTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
  end

  test "can create a post with valid attributes" do
    post = Post.new(title: "Taco Tuesday", description: "Making tacos", meal_date: 1.day.from_now, user: @user)
    assert post.save
  end

  test "post has a title" do
    assert_equal "Homemade Lasagna Night", posts(:one).title
  end

  test "post has a description" do
    assert_not_nil posts(:one).description
  end

  test "post has a meal_date" do
    assert_not_nil posts(:one).meal_date
  end

  test "post belongs to a user" do
    post = posts(:one)
    assert_respond_to post, :user
    assert_instance_of User, post.user
  end

  test "post requires a user" do
    post = Post.new(title: "No User Post", description: "desc", meal_date: 1.day.from_now)
    assert_not post.save
  end

  # title validation
  test "invalid without title" do
    post = Post.new(description: "desc", meal_date: 1.day.from_now, user: @user)
    assert_not post.valid?
    assert_includes post.errors[:title], "can't be blank"
  end

  test "invalid when title exceeds 100 characters" do
    post = Post.new(title: "a" * 101, user: @user)
    assert_not post.valid?
    assert post.errors[:title].any?
  end

  test "valid with title at exactly 100 characters" do
    post = Post.new(title: "a" * 100, user: @user)
    assert post.valid?
  end

  # description validation
  test "invalid when description exceeds 2000 characters" do
    post = Post.new(title: "Dinner", description: "a" * 2001, user: @user)
    assert_not post.valid?
    assert post.errors[:description].any?
  end

  test "valid with description at exactly 2000 characters" do
    post = Post.new(title: "Dinner", description: "a" * 2000, user: @user)
    assert post.valid?
  end

  test "valid without description" do
    post = Post.new(title: "Dinner", user: @user)
    assert post.valid?
  end

  # meal_date validation
  test "invalid when meal_date is more than 6 months in the future" do
    post = Post.new(title: "Far Future", user: @user, meal_date: 7.months.from_now)
    assert_not post.valid?
    assert post.errors[:meal_date].any?
  end

  test "valid when meal_date is within 6 months" do
    post = Post.new(title: "Soon", user: @user, meal_date: 5.months.from_now)
    assert post.valid?
  end

  test "valid with nil meal_date" do
    post = Post.new(title: "No Date", user: @user, meal_date: nil)
    assert post.valid?
  end

  # active scope
  test "active scope includes post with future meal_date" do
    post = Post.create!(title: "Future", description: "d", meal_date: 2.days.from_now, user: @user)
    assert_includes Post.active, post
  end

  test "active scope includes post with nil meal_date" do
    post = Post.create!(title: "No Date", description: "d", meal_date: nil, user: @user)
    assert_includes Post.active, post
  end

  test "active scope excludes post older than 36 hours" do
    post = Post.create!(title: "Old", description: "d", meal_date: 37.hours.ago, user: @user)
    assert_not_includes Post.active, post
  end

  # archived scope
  test "archived scope includes post older than 36 hours" do
    post = Post.create!(title: "Archived", description: "d", meal_date: 37.hours.ago, user: @user)
    assert_includes Post.archived, post
  end

  test "archived scope excludes post with future meal_date" do
    post = Post.create!(title: "Future", description: "d", meal_date: 2.days.from_now, user: @user)
    assert_not_includes Post.archived, post
  end

  test "archived scope excludes post with nil meal_date" do
    post = Post.create!(title: "No Date", description: "d", meal_date: nil, user: @user)
    assert_not_includes Post.archived, post
  end

  # dietary restrictions
  test "dietary_restrictions defaults to empty array" do
    post = Post.create!(title: "Dinner", user: @user)
    assert_equal [], post.dietary_restrictions
  end

  test "can save dietary restrictions" do
    post = Post.create!(title: "Vegan Night", user: @user, dietary_restrictions: [ "vegan", "gluten_free" ])
    assert_equal [ "vegan", "gluten_free" ], post.reload.dietary_restrictions
  end

  test "can clear dietary restrictions" do
    post = Post.create!(title: "Dinner", user: @user, dietary_restrictions: [ "vegan" ])
    post.update!(dietary_restrictions: [])
    assert_equal [], post.reload.dietary_restrictions
  end

  test "dietary restrictions persist across reloads" do
    post = Post.create!(title: "Dinner", user: @user, dietary_restrictions: [ "kosher", "nut_free" ])
    assert_equal [ "kosher", "nut_free" ], Post.find(post.id).dietary_restrictions
  end

  # DB constraint tests — bypass model validations with update_column / save(validate: false)
  test "database enforces title NOT NULL constraint" do
    post = Post.create!(title: "Test", user: @user)
    assert_raises(ActiveRecord::NotNullViolation) { post.update_column(:title, nil) }
  end

  test "database rejects nil title even when model validations are skipped" do
    post = Post.new(title: nil, user: @user)
    assert_raises(ActiveRecord::NotNullViolation) { post.save(validate: false) }
  end
end
