# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
users_data = [
  { username: "alice", email: "alice@example.com", bio: "Food lover and home chef." },
  { username: "bob", email: "bob@example.com", bio: "Obsessed with trying new restaurants." },
  { username: "carol", email: "carol@example.com", bio: "Vegetarian cook and recipe blogger." },
  { username: "dave", email: "dave@example.com", bio: "Weekend grillmaster." },
  { username: "eve", email: "eve@example.com", bio: "Baking enthusiast with a sweet tooth." }
]

posts_data = [
  [
    { title: "Homemade Pasta", description: "Fresh fettuccine with a rich tomato sauce.", meal_date: 3.days.ago },
    { title: "Avocado Toast", description: "Sourdough with smashed avocado and poached eggs.", meal_date: 2.days.ago },
    { title: "Lemon Risotto", description: "Creamy arborio rice with lemon zest and parmesan.", meal_date: 1.day.ago }
  ],
  [
    { title: "Ramen Night", description: "Tonkotsu broth with chashu pork and soft-boiled egg.", meal_date: 5.days.ago },
    { title: "Tacos al Pastor", description: "Marinated pork tacos with pineapple salsa.", meal_date: 3.days.ago },
    { title: "Sushi Platter", description: "Assorted nigiri and maki from a local spot.", meal_date: 1.day.ago }
  ],
  [
    { title: "Veggie Stir Fry", description: "Seasonal vegetables tossed in ginger soy sauce over rice.", meal_date: 4.days.ago },
    { title: "Black Bean Tacos", description: "Crispy black bean tacos with mango salsa.", meal_date: 2.days.ago },
    { title: "Lentil Soup", description: "Hearty red lentil soup with cumin and coriander.", meal_date: 1.day.ago }
  ],
  [
    { title: "BBQ Ribs", description: "Slow-smoked pork ribs with house dry rub.", meal_date: 6.days.ago },
    { title: "Grilled Corn", description: "Street-style elote with cotija and chili powder.", meal_date: 4.days.ago },
    { title: "Brisket Sandwich", description: "Smoked brisket on brioche with pickles and mustard.", meal_date: 2.days.ago }
  ],
  [
    { title: "Sourdough Loaf", description: "Long-fermented sourdough with a crispy crust.", meal_date: 7.days.ago },
    { title: "Croissants", description: "Buttery laminated dough, baked golden.", meal_date: 3.days.ago },
    { title: "Chocolate Lava Cake", description: "Warm chocolate cake with a molten center.", meal_date: 1.day.ago }
  ]
]

users_data.each_with_index do |attrs, i|
  user = User.find_or_create_by!(email: attrs[:email]) do |u|
    u.username = attrs[:username]
    u.bio = attrs[:bio]
  end

  posts_data[i].each do |post_attrs|
    user.posts.find_or_create_by!(title: post_attrs[:title]) do |p|
      p.description = post_attrs[:description]
      p.meal_date = post_attrs[:meal_date]
    end
  end
end

