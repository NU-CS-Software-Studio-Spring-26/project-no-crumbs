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
  { username: "alice",   email: "alice@example.com",   bio: "Home chef obsessed with Italian food.", password: "password123" },
  { username: "bob",     email: "bob@example.com",     bio: "Ramen devotee and street food hunter.", password: "password123" },
  { username: "carol",   email: "carol@example.com",   bio: "Plant-based cook and recipe blogger.", password: "password123" },
  { username: "dave",    email: "dave@example.com",    bio: "Weekend grillmaster and BBQ competitor.", password: "password123" },
  { username: "eve",     email: "eve@example.com",     bio: "Pastry nerd with a sourdough obsession.", password: "password123" },
  { username: "frank",   email: "frank@example.com",   bio: "Amateur sommelier and dinner party host.", password: "password123" },
  { username: "grace",   email: "grace@example.com",   bio: "Southeast Asian food fanatic living abroad.", password: "password123" },
  { username: "henry",   email: "henry@example.com",   bio: "Meal-prep king — eats the same thing all week.", password: "password123" },
  { username: "isabel",  email: "isabel@example.com",  bio: "Pescatarian who photographs everything she eats.", password: "password123" },
  { username: "jordan",  email: "jordan@example.com",  bio: "Late-night diner and midnight snack specialist.", password: "password123" }
]

posts_data = [
  # alice
  [
    { title: "Cacio e Pepe", description: "Spaghetti tossed with Pecorino Romano and freshly cracked pepper — no cream, ever.", meal_date: 5.days.ago },
    { title: "Chicken Piccata", description: "Pan-seared chicken in a lemon caper butter sauce over angel hair.", meal_date: 3.days.ago },
    { title: "Tiramisu", description: "Classic ladyfinger and mascarpone dessert soaked in espresso and Kahlúa.", meal_date: 1.day.ago }
  ],
  # bob
  [
    { title: "Tonkotsu Ramen", description: "12-hour pork bone broth with chashu, soft egg, nori, and bamboo shoots.", meal_date: 6.days.ago },
    { title: "Banh Mi", description: "Crusty baguette loaded with pâté, pickled daikon, jalapeño, and cilantro.", meal_date: 4.days.ago },
    { title: "Pad Thai", description: "Wok-fried rice noodles with shrimp, tamarind, fish sauce, and crushed peanuts.", meal_date: 1.day.ago }
  ],
  # carol
  [
    { title: "Mushroom Wellington", description: "Savory mushroom duxelles wrapped in golden puff pastry — totally plant-based.", meal_date: 7.days.ago },
    { title: "Chickpea Shakshuka", description: "Spiced tomato and pepper sauce with poached eggs and chickpeas, served with pita.", meal_date: 3.days.ago },
    { title: "Miso Glazed Eggplant", description: "Broiled eggplant with white miso and sesame over short-grain rice.", meal_date: 1.day.ago }
  ],
  # dave
  [
    { title: "St. Louis Ribs", description: "Competition-style spare ribs with a dry rub, smoked low and slow for 6 hours.", meal_date: 8.days.ago },
    { title: "Smash Burgers", description: "Double smash patties on a griddle with American cheese, pickles, and special sauce.", meal_date: 4.days.ago },
    { title: "Brisket Tacos", description: "12-hour smoked brisket chopped and served on corn tortillas with salsa verde.", meal_date: 2.days.ago }
  ],
  # eve
  [
    { title: "Country Sourdough", description: "Long cold-fermented loaf with an open crumb and blistered crust.", meal_date: 9.days.ago },
    { title: "Kouign-Amann", description: "Breton caramelized butter cake — crispy edges, pillowy center.", meal_date: 5.days.ago },
    { title: "Chocolate Babka", description: "Swirled enriched dough loaded with dark chocolate and cinnamon.", meal_date: 2.days.ago }
  ],
  # frank
  [
    { title: "Duck Confit", description: "Slow-cooked duck leg with lentils du Puy and a red wine reduction.", meal_date: 6.days.ago },
    { title: "Beef Bourguignon", description: "Braised beef with pearl onions, mushrooms, and a whole bottle of Burgundy.", meal_date: 3.days.ago },
    { title: "Cheese Board", description: "Aged Gouda, Époisses, Manchego, with honeycomb, fig jam, and marcona almonds.", meal_date: 1.day.ago }
  ],
  # grace
  [
    { title: "Khao Soi", description: "Northern Thai coconut curry noodle soup with crispy egg noodles and pickled mustard greens.", meal_date: 5.days.ago },
    { title: "Larb Moo", description: "Minced pork salad with fish sauce, lime, toasted rice powder, and fresh herbs.", meal_date: 3.days.ago },
    { title: "Nasi Lemak", description: "Coconut rice with sambal, fried anchovies, roasted peanuts, cucumber, and a fried egg.", meal_date: 1.day.ago }
  ],
  # henry
  [
    { title: "Turkey Meal Prep Bowls", description: "Ground turkey, roasted broccoli, brown rice, and a sriracha drizzle — five days sorted.", meal_date: 7.days.ago },
    { title: "Greek Chicken Wraps", description: "Marinated grilled chicken, tzatziki, cucumber, and feta in a whole wheat wrap.", meal_date: 4.days.ago },
    { title: "Overnight Oats", description: "Oats soaked in almond milk with chia seeds, banana, and peanut butter.", meal_date: 1.day.ago }
  ],
  # isabel
  [
    { title: "Seared Salmon", description: "Crispy-skin salmon over pea purée with a dill crème fraîche.", meal_date: 6.days.ago },
    { title: "Tuna Poke Bowl", description: "Ahi tuna, edamame, avocado, mango, and spicy mayo over sushi rice.", meal_date: 3.days.ago },
    { title: "Shrimp Tacos", description: "Grilled shrimp with chipotle slaw, avocado crema, and pickled red onion.", meal_date: 1.day.ago }
  ],
  # jordan
  [
    { title: "Midnight Grilled Cheese", description: "Gruyère and sharp cheddar on thick sourdough, pan-fried in brown butter.", meal_date: 5.days.ago },
    { title: "Spicy Instant Ramen Upgrade", description: "Shin Ramyun with a soft egg, sliced scallions, butter, and a splash of soy.", meal_date: 3.days.ago },
    { title: "Diner-Style Pancakes", description: "Fluffy buttermilk pancakes at 2am with real maple syrup and bacon on the side.", meal_date: 1.day.ago }
  ]
]

# Each pair is [requester_index, receiver_index] into the users array
friendships_data = [
  [ 0, 1 ],  # alice  <-> bob
  [ 0, 2 ],  # alice  <-> carol
  [ 0, 5 ],  # alice  <-> frank
  [ 1, 3 ],  # bob    <-> dave
  [ 1, 6 ],  # bob    <-> grace
  [ 2, 7 ],  # carol  <-> henry
  [ 3, 4 ],  # dave   <-> eve
  [ 4, 5 ],  # eve    <-> frank
  [ 5, 8 ],  # frank  <-> isabel
  [ 6, 9 ],  # grace  <-> jordan
  [ 7, 9 ],  # henry  <-> jordan
  [ 8, 9 ]   # isabel <-> jordan
]

users = users_data.each_with_index.map do |attrs, i|
  user = User.find_or_create_by!(email: attrs[:email]) do |u|
    u.username = attrs[:username]
    u.bio = attrs[:bio]
    u.password = attrs[:password]
  end

  posts_data[i].each do |post_attrs|
    user.posts.find_or_create_by!(title: post_attrs[:title]) do |p|
      p.description = post_attrs[:description]
      p.meal_date = post_attrs[:meal_date]
    end
  end

  user
end

friendships_data.each do |requester_idx, receiver_idx|
  requester = users[requester_idx]
  receiver  = users[receiver_idx]
  Friendship.find_or_create_by!(requester: requester, receiver: receiver) do |f|
    f.status = "accepted"
  end
end

alice = User.find_by!(email: "alice@example.com")
bob   = User.find_by!(email: "bob@example.com")
carol = User.find_by!(email: "carol@example.com")
dave  = User.find_by!(email: "dave@example.com")
eve   = User.find_by!(email: "eve@example.com")
frank = User.find_by!(email: "frank@example.com")

friendships_data = [
  { requester: alice, receiver: bob,   status: "accepted" },
  { requester: carol, receiver: alice, status: "accepted" },
  { requester: bob,   receiver: carol, status: "accepted" },
  { requester: carol, receiver: dave,  status: "accepted" },
  { requester: alice, receiver: dave,  status: "pending"  },
  { requester: eve,   receiver: bob,   status: "pending"  },
  { requester: dave,  receiver: eve,   status: "declined" }
]

friendships_data.each do |f|
  Friendship.find_or_create_by!(requester: f[:requester], receiver: f[:receiver]) do |fs|
    fs.status = f[:status]
  end
end

# ── Nick (the real user) ──────────────────────────────────────────────────────
nick = User.find_or_create_by!(email: "nperry248@gmail.com") do |u|
  u.username = "nperry"
  u.bio      = "Always down to eat."
  u.password = "password123"
end

# Nick's upcoming meals (active, so friends can RSVP to them)
nick_bbq = nick.posts.find_or_create_by!(title: "Backyard BBQ Bash") do |p|
  p.description = "Burgers, dogs, ribs — the whole spread. BYOB and bring a side."
  p.meal_date   = 2.days.from_now.change(hour: 17, min: 0)
end

nick_sushi = nick.posts.find_or_create_by!(title: "Homemade Sushi Night") do |p|
  p.description = "Rolling our own maki and nigiri. I'll have all the fish — just show up hungry."
  p.meal_date   = 5.days.from_now.change(hour: 19, min: 30)
end

# Friends' upcoming meals (so Nick has something to RSVP to)
alice_pasta = alice.posts.find_or_create_by!(title: "Garden Pasta Night") do |p|
  p.description = "Fresh pappardelle with cherry tomatoes, basil, and burrata straight from the garden."
  p.meal_date   = 3.days.from_now.change(hour: 18, min: 30)
end

bob_ramen = bob.posts.find_or_create_by!(title: "Sunday Ramen Session") do |p|
  p.description = "Spent all day on the broth — tonkotsu with all the toppings. Limited seats."
  p.meal_date   = 4.days.from_now.change(hour: 19, min: 0)
end

frank_wine = frank.posts.find_or_create_by!(title: "Wine & Cheese Evening") do |p|
  p.description = "Pairing six cheeses with natural wines. A quiet one — max 6 people."
  p.meal_date   = 7.days.from_now.change(hour: 20, min: 0)
end

# Friendships connecting Nick to the existing crew
[
  { requester: nick, receiver: alice },
  { requester: nick, receiver: bob   },
  { requester: nick, receiver: carol },
  { requester: frank, receiver: nick }
].each do |f|
  Friendship.find_or_create_by!(requester: f[:requester], receiver: f[:receiver]) do |fs|
    fs.status = "accepted"
  end
end

# RSVPs on Nick's meals (friends responding to his events)
{
  nick_bbq   => [ { user: alice, status: "going"     },
                  { user: bob,   status: "maybe"      },
                  { user: carol, status: "going"      },
                  { user: frank, status: "not_going"  } ],
  nick_sushi => [ { user: alice, status: "going"     },
                  { user: frank, status: "maybe"      } ]
}.each do |post, rsvps|
  rsvps.each do |r|
    Rsvp.find_or_create_by!(post: post, user: r[:user]) do |rsvp|
      rsvp.status = r[:status]
    end
  end
end

# Nick's RSVPs on friends' upcoming meals
{
  alice_pasta => "going",
  bob_ramen   => "maybe",
  frank_wine  => "going"
}.each do |post, status|
  Rsvp.find_or_create_by!(post: post, user: nick) do |rsvp|
    rsvp.status = status
  end
end
