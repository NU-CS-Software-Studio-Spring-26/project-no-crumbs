Given("a host user exists with email {string}") do |email|
  @host = create(:user, email: email, password: "password123", password_confirmation: "password123")
end

Given("a guest user exists with email {string}") do |email|
  @guest = create(:user, email: email, password: "password123", password_confirmation: "password123")
end

Given("a meal post {string} exists created by {string}") do |title, host_email|
  host = User.find_by!(email: host_email)
  @posts ||= {}
  @posts[title] = create(:post, title: title, user: host)
end

Given("I am logged in as {string}") do |email|
  @current_user = User.find_by!(email: email)
  login_as(@current_user, scope: :user)
end

Given("I am not logged in") do
  # no-op: Warden test mode starts with no authenticated user
end

Given("I have already RSVPed {string} to {string}") do |status, post_title|
  post = Post.find_by!(title: post_title)
  create(:rsvp, user: @current_user, post: post, status: status)
end

Given("the meal {string} has already passed") do |post_title|
  Post.find_by!(title: post_title).update_columns(meal_date: 2.days.ago)
end

When("I visit the {string} meal post") do |post_title|
  post = Post.find_by!(title: post_title)
  visit post_path(post)
end

When("I click the {string} RSVP button") do |label|
  click_button label
end

Then("the {string} button should be highlighted as active") do |label|
  expect(page).to have_css(".rsvp-btn-active", text: label)
end

Then("the {string} button should not be highlighted as active") do |label|
  expect(page).not_to have_css(".rsvp-btn-active", text: label)
end

Then("no RSVP button should be highlighted as active") do
  expect(page).not_to have_css(".rsvp-btn-active")
end

Then("I should not see any RSVP buttons") do
  expect(page).not_to have_css(".rsvp-btn-group")
end

When("I submit an RSVP to the {string} meal as {string}") do |post_title, status|
  post = Post.find_by!(title: post_title)
  page.driver.browser.post(post_rsvp_path(post), { status: status })
end

Then("I should be redirected to the sign-in page") do
  expect(page.driver.browser.last_response.status).to eq(302)
  expect(page.driver.browser.last_response.location).to include(new_user_session_path)
end

Then("I should see {string}") do |text|
  expect(page).to have_content(text)
end

Then("I should not see {string}") do |text|
  expect(page).not_to have_content(text)
end
