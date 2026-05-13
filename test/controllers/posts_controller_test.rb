require "test_helper"

class PostsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @post = posts(:one)
    sign_in users(:one)
  end

  test "should get index" do
    get posts_url
    assert_response :success
  end

  test "should get new" do
    get new_post_url
    assert_response :success
  end

  test "should create post" do
    assert_difference("Post.count") do
      post posts_url, params: { post: { description: @post.description, meal_date: @post.meal_date, title: "New Post" } }
    end

    assert_redirected_to post_url(Post.last, from_create: 1)
  end

  test "should show post" do
    get post_url(@post)
    assert_response :success
  end

  test "should get edit" do
    get edit_post_url(@post)
    assert_response :success
  end

  test "should update post" do
    patch post_url(@post), params: { post: { description: @post.description, meal_date: @post.meal_date, title: @post.title } }
    assert_redirected_to post_url(@post, from_edit: 1)
  end

  test "should destroy post" do
    assert_difference("Post.count", -1) do
      delete post_url(@post)
    end

    assert_redirected_to posts_url
  end

  # Authorization
  test "non-owner cannot edit another user's post" do
    sign_in users(:two)
    get edit_post_url(@post)
    assert_redirected_to post_url(@post)
  end

  test "non-owner cannot update another user's post" do
    sign_in users(:two)
    patch post_url(@post), params: { post: { title: "Hacked" } }
    assert_redirected_to post_url(@post)
  end

  test "non-owner cannot destroy another user's post" do
    sign_in users(:two)
    assert_no_difference("Post.count") do
      delete post_url(@post)
    end
    assert_redirected_to post_url(@post)
  end

  # Authentication
  test "unauthenticated user is redirected from index" do
    sign_out :user
    get posts_url
    assert_redirected_to new_user_session_path
  end

  test "unauthenticated user is redirected from new" do
    sign_out :user
    get new_post_url
    assert_redirected_to new_user_session_path
  end

  # dietary restrictions
  test "can save dietary restrictions on create" do
    post posts_url, params: { post: { title: "Vegan Night", meal_date: 1.day.from_now, dietary_restrictions: [ "vegan", "dairy_free" ] } }
    assert_equal [ "vegan", "dairy_free" ], Post.last.dietary_restrictions
  end

  test "can save dietary restrictions on update" do
    patch post_url(@post), params: { post: { title: @post.title, dietary_restrictions: [ "gluten_free" ] } }
    assert_equal [ "gluten_free" ], @post.reload.dietary_restrictions
  end

  test "can clear dietary restrictions by submitting empty sentinel" do
    @post.update!(dietary_restrictions: [ "vegan" ])
    patch post_url(@post), params: { post: { title: @post.title, dietary_restrictions: [ "" ] } }
    assert_equal [], @post.reload.dietary_restrictions
  end

  test "ignores blank values in dietary restrictions" do
    patch post_url(@post), params: { post: { title: @post.title, dietary_restrictions: [ "", "kosher" ] } }
    assert_equal [ "kosher" ], @post.reload.dietary_restrictions
  end
end
