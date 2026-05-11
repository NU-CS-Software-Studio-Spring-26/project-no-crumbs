require "test_helper"

class PagesControllerTest < ActionDispatch::IntegrationTest
  test "should get about when logged out" do
    get about_url
    assert_response :success
  end

  test "should get legal when logged out" do
    get legal_url
    assert_response :success
  end

  test "should get about when logged in" do
    sign_in users(:one)
    get about_url
    assert_response :success
  end

  test "should get legal when logged in" do
    sign_in users(:one)
    get legal_url
    assert_response :success
  end

  test "about page contains footer link to legal" do
    get about_url
    assert_select "footer a[href=?]", legal_path
  end

  test "about page contains footer link to github" do
    get about_url
    assert_select "footer a[href*=?]", "github.com"
  end

  test "legal page contains footer link to about" do
    get legal_url
    assert_select "footer a[href=?]", about_path
  end
end
