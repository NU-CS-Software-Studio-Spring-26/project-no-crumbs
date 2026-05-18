require "set"

# ── Unsplash photo pool ────────────────────────────────────────────────────────
# Run `rails unsplash:prefetch_seed_urls` once and paste the output here.
SEED_PHOTO_URLS = [
  "https://images.unsplash.com/photo-1588013273468-315fd88ea34c?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w5NDQ1MDl8MHwxfHNlYXJjaHwxfHxwYXN0YSUyMGNhcmJvbmFyYXxlbnwwfDB8fHwxNzc5MDc1ODQ2fDA&ixlib=rb-4.1.0&q=80&w=1080",
  "https://images.unsplash.com/photo-1623341214825-9f4f963727da?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w5NDQ1MDl8MHwxfHNlYXJjaHwxfHxyYW1lbiUyMGJvd2x8ZW58MHwwfHx8MTc3OTA3NTg0Nnww&ixlib=rb-4.1.0&q=80&w=1080",
  "https://images.unsplash.com/photo-1579871494447-9811cf80d66c?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w5NDQ1MDl8MHwxfHNlYXJjaHwxfHxzdXNoaSUyMHJvbGxzfGVufDB8MHx8fDE3NzkwNzU4NDd8MA&ixlib=rb-4.1.0&q=80&w=1080",
  "https://images.unsplash.com/photo-1544025162-d76694265947?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w5NDQ1MDl8MHwxfHNlYXJjaHwxfHxiYnElMjByaWJzfGVufDB8MHx8fDE3NzkwNzU4NDh8MA&ixlib=rb-4.1.0&q=80&w=1080",
  "https://images.unsplash.com/photo-1648437595587-e6a8b0cdf1f9?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w5NDQ1MDl8MHwxfHNlYXJjaHwxfHxzdHJlZXQlMjB0YWNvc3xlbnwwfDB8fHwxNzc5MDc1ODQ4fDA&ixlib=rb-4.1.0&q=80&w=1080",
  "https://images.unsplash.com/photo-1588137378633-dea1336ce1e2?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w5NDQ1MDl8MHwxfHNlYXJjaHwxfHxhdm9jYWRvJTIwdG9hc3R8ZW58MHwwfHx8MTc3OTA3NTg0OXww&ixlib=rb-4.1.0&q=80&w=1080",
  "https://images.unsplash.com/photo-1513104890138-7c749659a591?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w5NDQ1MDl8MHwxfHNlYXJjaHwxfHxtYXJnaGVyaXRhJTIwcGl6emF8ZW58MHwwfHx8MTc3OTA3NTg0OXww&ixlib=rb-4.1.0&q=80&w=1080",
  "https://images.unsplash.com/photo-1568901346375-23c9450c58cd?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w5NDQ1MDl8MHwxfHNlYXJjaHwxfHxzbWFzaCUyMGJ1cmdlcnxlbnwwfDB8fHwxNzc5MDc1ODUwfDA&ixlib=rb-4.1.0&q=80&w=1080",
  "https://images.unsplash.com/photo-1607532941433-304659e8198a?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w5NDQ1MDl8MHwxfHNlYXJjaHwxfHxjYWVzYXIlMjBzYWxhZHxlbnwwfDB8fHwxNzc5MDc1ODUwfDA&ixlib=rb-4.1.0&q=80&w=1080",
  "https://images.unsplash.com/photo-1558030006-450675393462?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w5NDQ1MDl8MHwxfHNlYXJjaHwxfHxncmlsbGVkJTIwc3RlYWt8ZW58MHwwfHx8MTc3OTA3NTg1MXww&ixlib=rb-4.1.0&q=80&w=1080",
  "https://images.unsplash.com/photo-1603894584373-5ac82b2ae398?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w5NDQ1MDl8MHwxfHNlYXJjaHwxfHxjaGlja2VuJTIwY3Vycnl8ZW58MHwwfHx8MTc3OTA3NTg1Mnww&ixlib=rb-4.1.0&q=80&w=1080",
  "https://images.unsplash.com/photo-1604259597308-5321e8e4789c?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w5NDQ1MDl8MHwxfHNlYXJjaHwxfHxwb2tlJTIwYm93bHxlbnwwfDB8fHwxNzc5MDc1ODUzfDA&ixlib=rb-4.1.0&q=80&w=1080",
  "https://images.unsplash.com/photo-1541288097308-7b8e3f58c4c6?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w5NDQ1MDl8MHwxfHNlYXJjaHwxfHxmbHVmZnklMjBwYW5jYWtlc3xlbnwwfDB8fHwxNzc5MDc1ODU0fDA&ixlib=rb-4.1.0&q=80&w=1080",
  "https://images.unsplash.com/photo-1519708227418-c8fd9a32b7a2?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w5NDQ1MDl8MHwxfHNlYXJjaHwxfHxncmlsbGVkJTIwc2FsbW9ufGVufDB8MHx8fDE3NzkwNzU4NTR8MA&ixlib=rb-4.1.0&q=80&w=1080",
  "https://images.unsplash.com/photo-1569058242253-92a9c755a0ec?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w5NDQ1MDl8MHwxfHNlYXJjaHwxfHxmcmllZCUyMGNoaWNrZW58ZW58MHwwfHx8MTc3OTA3NTg1NXww&ixlib=rb-4.1.0&q=80&w=1080",
  "https://images.unsplash.com/photo-1597604391235-a7429b4b350c?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w5NDQ1MDl8MHwxfHNlYXJjaHwxfHxzb3VyZG91Z2glMjBicmVhZHxlbnwwfDB8fHwxNzc5MDc1ODU1fDA&ixlib=rb-4.1.0&q=80&w=1080",
  "https://images.unsplash.com/photo-1606983340126-99ab4feaa64a?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w5NDQ1MDl8MHwxfHNlYXJjaHwxfHxjaG9jb2xhdGUlMjBjYWtlfGVufDB8MHx8fDE3NzkwNzU4NTZ8MA&ixlib=rb-4.1.0&q=80&w=1080",
  "https://images.unsplash.com/photo-1668094497457-29f4bd775c95?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w5NDQ1MDl8MHwxfHNlYXJjaHwxfHxjaGVlc2UlMjBib2FyZHxlbnwwfDB8fHwxNzc5MDc1ODU3fDA&ixlib=rb-4.1.0&q=80&w=1080",
  "https://images.unsplash.com/photo-1549203438-a7696aed4dac?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w5NDQ1MDl8MHwxfHNlYXJjaHwxfHxmcmVuY2glMjBvbmlvbiUyMHNvdXB8ZW58MHwwfHx8MTc3OTA3NTg1OHww&ixlib=rb-4.1.0&q=80&w=1080",
  "https://images.unsplash.com/photo-1662230786065-154eafffa3e6?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w5NDQ1MDl8MHwxfHNlYXJjaHwxfHx0aXJhbWlzdSUyMGRlc3NlcnR8ZW58MHwwfHx8MTc3OTA3NTg1OHww&ixlib=rb-4.1.0&q=80&w=1080",
  "https://images.unsplash.com/photo-1523905330026-b8bd1f5f320e?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w5NDQ1MDl8MHwxfHNlYXJjaHwxfHxkaW0lMjBzdW0lMjBkdW1wbGluZ3N8ZW58MHwwfHx8MTc3OTA3NTg1OXww&ixlib=rb-4.1.0&q=80&w=1080",
  "https://images.unsplash.com/photo-1680990999782-ba7fe26e4d0b?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w5NDQ1MDl8MHwxfHNlYXJjaHwxfHxmYWxhZmVsJTIwd3JhcHxlbnwwfDB8fHwxNzc5MDc1ODU5fDA&ixlib=rb-4.1.0&q=80&w=1080",
  "https://images.unsplash.com/photo-1633964913295-ceb43826e7c9?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w5NDQ1MDl8MHwxfHNlYXJjaHwxfHxtdXNocm9vbSUyMHJpc290dG98ZW58MHwwfHx8MTc3OTA3NTg2MHww&ixlib=rb-4.1.0&q=80&w=1080",
  "https://images.unsplash.com/photo-1627309302198-09a50ae1b209?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w5NDQ1MDl8MHwxfHNlYXJjaHwxfHxiYW5oJTIwbWklMjBzYW5kd2ljaHxlbnwwfDB8fHwxNzc5MDc1ODYxfDA&ixlib=rb-4.1.0&q=80&w=1080",
  "https://images.unsplash.com/photo-1683533738338-19b9a22c6405?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w5NDQ1MDl8MHwxfHNlYXJjaHwxfHxjb2NvbnV0JTIwY3Vycnl8ZW58MHwwfHx8MTc3OTA3NTg2MXww&ixlib=rb-4.1.0&q=80&w=1080",
  "https://images.unsplash.com/photo-1542895364-1f38d277f031?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w5NDQ1MDl8MHwxfHNlYXJjaHwxfHxzaGFrc2h1a2ElMjBlZ2dzfGVufDB8MHx8fDE3NzkwNzU4NjJ8MA&ixlib=rb-4.1.0&q=80&w=1080",
  "https://images.unsplash.com/photo-1559314809-0d155014e29e?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w5NDQ1MDl8MHwxfHNlYXJjaHwxfHxwYWQlMjB0aGFpJTIwbm9vZGxlc3xlbnwwfDB8fHwxNzc5MDc1ODYzfDA&ixlib=rb-4.1.0&q=80&w=1080",
  "https://images.unsplash.com/photo-1600289031464-74d374b64991?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w5NDQ1MDl8MHwxfHNlYXJjaHwxfHxiaWJpbWJhcCUyMGtvcmVhbnxlbnwwfDB8fHwxNzc5MDc1ODYzfDA&ixlib=rb-4.1.0&q=80&w=1080",
  "https://images.unsplash.com/photo-1707995548052-cfca47bfb6db?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w5NDQ1MDl8MHwxfHNlYXJjaHwxfHxsb2JzdGVyJTIwc2VhZm9vZHxlbnwwfDB8fHwxNzc5MDc1ODY0fDA&ixlib=rb-4.1.0&q=80&w=1080",
  "https://images.unsplash.com/photo-1599974579688-8dbdd335c77f?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w5NDQ1MDl8MHwxfHNlYXJjaHwxfHxiZWVmJTIwdGFjb3N8ZW58MHwwfHx8MTc3OTA3NTg2NHww&ixlib=rb-4.1.0&q=80&w=1080",
  "https://images.unsplash.com/photo-1592578630143-fac65cda7a67?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w5NDQ1MDl8MHwxfHNlYXJjaHwxfHx2ZWdnaWUlMjBzdGlyJTIwZnJ5fGVufDB8MHx8fDE3NzkwNzU4NjV8MA&ixlib=rb-4.1.0&q=80&w=1080",
  "https://images.unsplash.com/photo-1654923064926-be7e64267a31?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w5NDQ1MDl8MHwxfHNlYXJjaHwxfHxhY2FpJTIwc21vb3RoaWUlMjBib3dsfGVufDB8MHx8fDE3NzkwNzU4NjZ8MA&ixlib=rb-4.1.0&q=80&w=1080",
  "https://images.unsplash.com/photo-1606728035253-49e8a23146de?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w5NDQ1MDl8MHwxfHNlYXJjaHwxfHxyb2FzdCUyMGNoaWNrZW58ZW58MHwwfHx8MTc3OTA3NTg2N3ww&ixlib=rb-4.1.0&q=80&w=1080",
  "https://images.unsplash.com/photo-1542528180-0c79567c66de?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w5NDQ1MDl8MHwxfHNlYXJjaHwxfHxodW1tdXMlMjBtZXp6ZXxlbnwwfDB8fHwxNzc5MDc1ODY3fDA&ixlib=rb-4.1.0&q=80&w=1080",
  "https://images.unsplash.com/photo-1708184528301-b0dad28dded5?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w5NDQ1MDl8MHwxfHNlYXJjaHwxfHxtYWMlMjBhbmQlMjBjaGVlc2V8ZW58MHwwfHx8MTc3OTA3NTg2OHww&ixlib=rb-4.1.0&q=80&w=1080",
].freeze

DIETARY_OPTIONS = %w[vegetarian vegan gluten_free dairy_free nut_free shellfish_free halal kosher].freeze

FOOD_COMMENTS = [
  "This looks incredible!",
  "Adding this to my must-try list.",
  "The flavors sound perfect together.",
  "Would love to join next time!",
  "Making this for my family this weekend.",
  "Classic. Can't go wrong.",
  "Where did you get the recipe?",
  "This is exactly my kind of meal.",
  "I've been craving this all week.",
  "Saving this post!",
  "The presentation alone is worth it.",
  "Restaurant quality right here.",
  "How long did this take to make?",
  "Been meaning to try this forever.",
  "Looks absolutely perfect.",
  "I need to get invited to this.",
  "This is the move.",
  "Genuinely obsessed with this combo.",
  "Making this ASAP.",
  "This hit different.",
  "No notes. Perfection.",
  "I would eat this every day.",
  "The smell must be incredible.",
  "You're a menace for posting this at midnight.",
  "Okay I'm officially hungry now.",
].freeze

SEED_BIOS = [
  "Home cook always chasing the next great meal.",
  "I eat therefore I am.",
  "Amateur chef, professional eater.",
  "Food is my love language.",
  "Cooking for friends is my cardio.",
  "Will travel for good food.",
  "Grew up in the kitchen, never left.",
  "Obsessed with trying every cuisine at least once.",
  "I rate every meal out of ten. My standards are high.",
  "Meal prepper by week, indulger by weekend.",
  "My fridge is always full. My wallet is always empty.",
  "Firm believer that butter fixes everything.",
  "Brunch is a personality trait and I'm owning it.",
  "Late-night snack enthusiast.",
  "I host dinners. It's the only way I make friends.",
  "Trying to learn every dish my grandmother made.",
  "Spice tolerance: dangerously high.",
  "I have opinions about ramen and I will share them.",
  "Food photographer with a phone camera and a dream.",
  "Plant-based most days. Cheese every day.",
  "I collect recipes the way other people collect debt.",
  "Cook first, ask questions later.",
  "You had me at charcuterie.",
  "Always the one who suggests the restaurant.",
  "Sourdough started as a hobby, now it's an identity.",
].freeze

NAMED_EMAILS = %w[
  admin@nocrumbs.com
  alice@example.com
  bob@example.com
  carol@example.com
  dave@example.com
  eve@example.com
  frank@example.com
  grace@example.com
  henry@example.com
  isabel@example.com
  jordan@example.com
  nperry248@gmail.com
].freeze

# ── Admin ──────────────────────────────────────────────────────────────────────
User.find_or_create_by!(email: "admin@nocrumbs.com") do |u|
  u.username = "admin"
  u.bio      = "Site administrator."
  u.password = "adminpassword123"
  u.admin    = true
end

# ── Named seed users ───────────────────────────────────────────────────────────
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

named_users = users_data.each_with_index.map do |attrs, i|
  user = User.find_or_create_by!(email: attrs[:email]) do |u|
    u.username = attrs[:username]
    u.bio      = attrs[:bio]
    u.password = attrs[:password]
  end

  posts_data[i].each do |post_attrs|
    user.posts.find_or_create_by!(title: post_attrs[:title]) do |p|
      p.description = post_attrs[:description]
      p.meal_date   = post_attrs[:meal_date]
    end
  end

  user
end

alice, bob, carol, dave, eve, frank, grace, henry, isabel, jordan = named_users

[
  { requester: alice, receiver: bob,   status: "accepted" },
  { requester: carol, receiver: alice, status: "accepted" },
  { requester: bob,   receiver: carol, status: "accepted" },
  { requester: carol, receiver: dave,  status: "accepted" },
  { requester: alice, receiver: dave,  status: "pending"  },
  { requester: eve,   receiver: bob,   status: "pending"  },
  { requester: dave,  receiver: eve,   status: "declined" }
].each do |f|
  Friendship.find_or_create_by!(requester: f[:requester], receiver: f[:receiver]) do |fs|
    fs.status = f[:status]
  end
end

# ── Nick (the real user) ───────────────────────────────────────────────────────
nick = User.find_or_create_by!(email: "nperry248@gmail.com") do |u|
  u.username = "nperry"
  u.bio      = "Always down to eat."
  u.password = "password123"
end

nick_bbq = nick.posts.find_or_create_by!(title: "Backyard BBQ Bash") do |p|
  p.description = "Burgers, dogs, ribs — the whole spread. BYOB and bring a side."
  p.meal_date   = 2.days.from_now.change(hour: 17, min: 0)
end

nick_sushi = nick.posts.find_or_create_by!(title: "Homemade Sushi Night") do |p|
  p.description = "Rolling our own maki and nigiri. I'll have all the fish — just show up hungry."
  p.meal_date   = 5.days.from_now.change(hour: 19, min: 30)
end

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

[
  { requester: nick,  receiver: alice },
  { requester: nick,  receiver: bob   },
  { requester: nick,  receiver: carol },
  { requester: frank, receiver: nick  }
].each do |f|
  Friendship.find_or_create_by!(requester: f[:requester], receiver: f[:receiver]) do |fs|
    fs.status = "accepted"
  end
end

{
  nick_bbq   => [ { user: alice, status: "going"    },
                  { user: bob,   status: "maybe"     },
                  { user: carol, status: "going"     },
                  { user: frank, status: "not_going" } ],
  nick_sushi => [ { user: alice, status: "going"    },
                  { user: frank, status: "maybe"     } ]
}.each do |post, rsvps|
  rsvps.each do |r|
    Rsvp.find_or_create_by!(post: post, user: r[:user]) { |rsvp| rsvp.status = r[:status] }
  end
end

{ alice_pasta => "going", bob_ramen => "maybe", frank_wine => "going" }.each do |post, status|
  Rsvp.find_or_create_by!(post: post, user: nick) { |rsvp| rsvp.status = status }
end

[
  { user: alice, post: nick_bbq    },
  { user: bob,   post: nick_bbq    },
  { user: carol, post: nick_bbq    },
  { user: nick,  post: alice_pasta },
  { user: bob,   post: alice_pasta },
  { user: nick,  post: bob_ramen   },
  { user: alice, post: bob_ramen   },
  { user: nick,  post: frank_wine  },
  { user: alice, post: nick_sushi  },
  { user: carol, post: nick_sushi  }
].each { |l| Like.find_or_create_by!(user: l[:user], likeable: l[:post]) }

[
  { user: alice, post: nick_bbq,    body: "Can't wait — I'm bringing potato salad!" },
  { user: bob,   post: nick_bbq,    body: "Should I grab extra charcoal on the way?" },
  { user: carol, post: nick_bbq,    body: "Making a veggie option to bring." },
  { user: nick,  post: alice_pasta, body: "That burrata detail has me sold. See you there." },
  { user: bob,   post: alice_pasta, body: "Fresh pappardelle is undefeated. Counting down." },
  { user: alice, post: bob_ramen,   body: "12 hours of broth?? You're insane (in the best way)." },
  { user: nick,  post: bob_ramen,   body: "Save me a seat. I'll bring the beer." },
  { user: nick,  post: frank_wine,  body: "Really hoping the Époisses makes the cut." },
  { user: alice, post: frank_wine,  body: "Do we need to bring anything?" },
  { user: alice, post: nick_sushi,  body: "I'll be the one who rolls everything wrong but has fun." },
  { user: carol, post: nick_sushi,  body: "I've been practicing my rolling. Game time." }
].each do |c|
  next if Comment.exists?(user: c[:user], post: c[:post], body: c[:body])
  Comment.create!(user: c[:user], post: c[:post], body: c[:body])
end

[
  { name: "NU Class of '26",    description: "Northwestern University class of 2026 — eat, cook, and share meals with your classmates.", creator: alice, members: [ alice, bob, carol, nick ] },
  { name: "Chicago Food Scene", description: "Exploring the best of Chicago's dining culture, one meal at a time.", creator: frank, members: [ frank, grace, isabel, nick ] },
  { name: "Meal Prep Crew",     description: "Plan your week, cook in bulk, and share what's in the rotation.", creator: henry, members: [ henry, carol, eve ] },
  { name: "Late Night Eaters",  description: "For people who eat dinner after midnight and have zero regrets.", creator: jordan, members: [ jordan, bob, nick ] }
].each do |data|
  community = Community.find_or_create_by!(name: data[:name]) do |c|
    c.description = data[:description]
    c.creator     = data[:creator]
  end
  data[:members].each do |user|
    role = user == data[:creator] ? "admin" : "member"
    CommunityMembership.find_or_create_by!(community: community, user: user) { |m| m.role = role }
  end
end

# ── Bulk seed (Faker users + realistic social graph) ───────────────────────────
existing_bulk_count = User.where.not(email: NAMED_EMAILS).count

if existing_bulk_count >= 150
  puts "Bulk data already seeded (#{existing_bulk_count} Faker users found). Skipping bulk section."
  puts "To reseed from scratch: rails db:seed:replant"
else
  puts "Seeding bulk data..."

  photo_pool = SEED_PHOTO_URLS.presence || []

  def generate_seed_username
    base = Faker::Internet.username(specifier: 5..20)
                          .downcase
                          .gsub(/[^a-z0-9_]/, "_")
                          .gsub(/_+/, "_")
                          .gsub(/\A_+|_+\z/, "")
                          .slice(0, 28)
    base = "user#{SecureRandom.hex(3)}" if base.length < 2

    candidate = base
    suffix    = 1
    while User.exists?(username: candidate)
      candidate = "#{base}_#{suffix}"
      suffix   += 1
    end
    candidate
  end

  # ── Build social clusters ──────────────────────────────────────────────────
  # 10 clusters of 19 users each = 190 Faker users
  # Users within a cluster are likely to be friends (same "social circle")
  CLUSTER_COUNT     = 10
  USERS_PER_CLUSTER = 19

  clusters    = []
  faker_users = []
  user_cluster_idx = {}

  print "Creating users"
  CLUSTER_COUNT.times do |ci|
    cluster = []
    USERS_PER_CLUSTER.times do
      email = nil
      loop do
        email = Faker::Internet.email
        break unless User.exists?(email: email)
      end

      user = User.create!(
        email:                email,
        username:             generate_seed_username,
        bio:                  SEED_BIOS.sample,
        password:             "password123",
        dietary_restrictions: DIETARY_OPTIONS.sample(rand(0..3))
      )
      cluster << user
      faker_users << user
      user_cluster_idx[user.id] = ci
      print "."
      $stdout.flush
    end
    clusters << cluster
  end
  puts " #{faker_users.size} users created."

  # ── Posts ──────────────────────────────────────────────────────────────────
  print "Creating posts"
  faker_posts       = []
  future_post_ids   = Set.new
  meal_hours        = [ 12, 13, 18, 19, 20 ]
  meal_minutes      = [ 0, 30 ]

  faker_users.each do |user|
    titles_used = Set.new
    5.times do
      title = Faker::Food.dish
      # Avoid duplicate titles per user
      title = "#{Faker::Food.dish} Night" if titles_used.include?(title)
      titles_used.add(title)
      next if Post.exists?(user: user, title: title)

      is_future = rand < 0.25
      meal_date = if is_future
        rand(2..13).days.from_now.change(hour: meal_hours.sample, min: meal_minutes.sample)
      else
        rand(1..150).days.ago.change(hour: meal_hours.sample, min: meal_minutes.sample)
      end

      post = Post.create!(
        user:            user,
        title:           title,
        description:     Faker::Food.description.truncate(500),
        meal_date:       meal_date,
        cover_photo_url: photo_pool.sample
      )
      faker_posts << post
      future_post_ids.add(post.id) if is_future
    end
    print "."
    $stdout.flush
  end
  puts " #{faker_posts.size} posts created."

  # ── Friendships ─────────────────────────────────────────────────────────────
  # Within-cluster: ~60% chance of friendship (tight social circles)
  # Cross-cluster:  random shuffle pairs (~5% of total, for loose cross-group ties)
  print "Creating friendships"
  friendship_pairs = Set.new  # stores sorted [id_a, id_b]

  clusters.each do |cluster|
    cluster.combination(2).each do |a, b|
      next unless rand < 0.6
      pair = [ a.id, b.id ].sort
      next if friendship_pairs.include?(pair)
      friendship_pairs.add(pair)
      Friendship.create!(requester_id: pair[0], receiver_id: pair[1], status: "accepted")
    end
  end

  # Shuffle all Faker users and pair consecutive ones for cross-cluster ties
  faker_users.shuffle.each_slice(2) do |a, b|
    next unless b
    next if user_cluster_idx[a.id] == user_cluster_idx[b.id]
    pair = [ a.id, b.id ].sort
    next if friendship_pairs.include?(pair)
    friendship_pairs.add(pair)
    status = rand < 0.8 ? "accepted" : "pending"
    Friendship.create!(requester_id: pair[0], receiver_id: pair[1], status: status)
  end

  # Build a fast friend-lookup map (user_id → [friend_ids])
  friend_map = Hash.new { |h, k| h[k] = [] }
  friendship_pairs.each do |pair|
    friend_map[pair[0]] << pair[1]
    friend_map[pair[1]] << pair[0]
  end

  user_by_id = faker_users.index_by(&:id)
  puts " #{friendship_pairs.size} friendships created."

  # ── RSVPs ──────────────────────────────────────────────────────────────────
  # Only friends RSVP to upcoming meals (~40% of friends respond)
  print "Creating RSVPs"
  rsvp_weights = %w[going going going maybe not_going]

  faker_posts.each do |post|
    next unless future_post_ids.include?(post.id)

    friend_ids = friend_map[post.user_id]
    next if friend_ids.empty?

    rsvp_count = (friend_ids.size * 0.4).ceil.clamp(1, friend_ids.size)
    friend_ids.sample(rsvp_count).each do |fid|
      friend = user_by_id[fid]
      next unless friend
      Rsvp.find_or_create_by!(post: post, user: friend) { |r| r.status = rsvp_weights.sample }
    end
    print "."
    $stdout.flush
  end
  puts " done."

  # ── Comments ───────────────────────────────────────────────────────────────
  # ~3 comments per post: 80% from friends, fill remainder from random users
  print "Creating comments"

  faker_posts.each do |post|
    friend_ids = friend_map[post.user_id]
    commenters = []

    # Pull from friends first
    if friend_ids.any?
      sample_size = [ 3, friend_ids.size ].min
      commenters = friend_ids.sample(sample_size).filter_map { |id| user_by_id[id] }
    end

    # Fill up to 3 with random non-friends if needed
    attempts = 0
    while commenters.size < 3 && attempts < 20
      candidate = faker_users.sample
      unless candidate == post.user || commenters.include?(candidate)
        commenters << candidate
      end
      attempts += 1
    end

    commenters.first(3).each do |commenter|
      Comment.create!(post: post, user: commenter, body: FOOD_COMMENTS.sample)
    end
    print "."
    $stdout.flush
  end
  puts " done."

  # ── Likes ──────────────────────────────────────────────────────────────────
  # Friends: ~30% like rate  |  Random non-friends: ~5% (viral reach)
  print "Creating likes"

  faker_posts.each do |post|
    friend_ids = friend_map[post.user_id]

    friend_ids.each do |fid|
      next unless rand < 0.3
      liker = user_by_id[fid]
      next unless liker
      Like.find_or_create_by!(user: liker, likeable: post)
    end

    faker_users.sample(8).each do |random_user|
      next if random_user.id == post.user_id
      next if friend_ids.include?(random_user.id)
      next unless rand < 0.05
      Like.find_or_create_by!(user: random_user, likeable: post)
    end
    print "."
    $stdout.flush
  end
  puts " done."

  # ── Faker communities ──────────────────────────────────────────────────────
  # Each community is anchored to a cluster (its "core"), with some cross-cluster members
  puts "Creating communities..."

  [
    { name: "Evanston Eats",        description: "Sharing the best home-cooked meals and restaurant finds around Evanston." },
    { name: "Vegan Vibes",          description: "Plant-based eaters sharing creative, satisfying vegan meals." },
    { name: "Sunday Brunch Club",   description: "For people who take brunch very, very seriously." },
    { name: "Spice Lovers",         description: "If it doesn't make you sweat, it's not spicy enough." },
    { name: "Late Night Kitchen",   description: "The best meals happen after midnight. No judgment here." },
    { name: "Asian Food Lovers",    description: "Celebrating the incredible diversity of Asian cuisines." },
    { name: "BBQ & Grill Masters",  description: "Smoke, fire, and meat. The art of outdoor cooking." },
    { name: "Bakers Anonymous",     description: "Sourdough, croissants, cakes — if it bakes, it belongs here." },
    { name: "Budget Foodies",       description: "Incredible food on a student budget. No truffle oil required." },
    { name: "Fine Dining at Home",  description: "Restaurant-quality meals made in your own kitchen." },
    { name: "Seafood Society",      description: "From poke bowls to lobster — all things from the sea." },
    { name: "Comfort Food Crew",    description: "Mac and cheese. Ramen. Grilled cheese. The classics." },
    { name: "Global Kitchen",       description: "A world tour through cuisine — one meal at a time." },
    { name: "Healthy Eats",         description: "Nutritious, balanced, and actually delicious meals." },
    { name: "Street Food Addicts",  description: "Tacos, banh mi, dumplings — the best food is found outside." },
  ].each_with_index do |data, i|
    next if Community.exists?(name: data[:name])

    core_cluster = clusters[i % CLUSTER_COUNT]
    creator      = core_cluster.first

    community = Community.create!(name: data[:name], description: data[:description], creator: creator)
    CommunityMembership.create!(community: community, user: creator, role: "admin")

    # ~80% of the core cluster join
    core_cluster[1..].each do |user|
      next unless rand < 0.8
      CommunityMembership.find_or_create_by!(community: community, user: user) { |m| m.role = "member" }
    end

    # 5–10 cross-cluster members (friends of core members who spill over)
    cross_members = (faker_users - core_cluster).sample(rand(5..10))
    cross_members.each do |user|
      CommunityMembership.find_or_create_by!(community: community, user: user) { |m| m.role = "member" }
    end
  end

  puts "Bulk seed complete."
end

# ── Final counts ───────────────────────────────────────────────────────────────
puts ""
puts "Seed finished!"
puts "  Users:        #{User.count}"
puts "  Posts:        #{Post.count}"
puts "  Friendships:  #{Friendship.count}"
puts "  RSVPs:        #{Rsvp.count}"
puts "  Comments:     #{Comment.count}"
puts "  Likes:        #{Like.count}"
puts "  Communities:  #{Community.count}"
