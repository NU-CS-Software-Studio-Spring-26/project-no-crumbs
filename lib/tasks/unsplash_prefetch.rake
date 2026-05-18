namespace :unsplash do
  desc "Fetch ~35 food photo URLs from Unsplash for seed data. Paste output into db/seeds.rb SEED_PHOTO_URLS."
  task prefetch_seed_urls: :environment do
    keywords = [
      "pasta carbonara", "ramen bowl", "sushi rolls", "bbq ribs", "street tacos",
      "avocado toast", "margherita pizza", "smash burger", "caesar salad", "grilled steak",
      "chicken curry", "poke bowl", "fluffy pancakes", "grilled salmon", "fried chicken",
      "sourdough bread", "chocolate cake", "cheese board", "french onion soup", "tiramisu dessert",
      "dim sum dumplings", "falafel wrap", "mushroom risotto", "banh mi sandwich", "coconut curry",
      "shakshuka eggs", "pad thai noodles", "bibimbap korean", "lobster seafood", "beef tacos",
      "veggie stir fry", "acai smoothie bowl", "roast chicken", "hummus mezze", "mac and cheese"
    ]

    puts "Fetching #{keywords.size} Unsplash food photos..."
    urls = []

    keywords.each do |kw|
      url = UnsplashService.fetch_photo_url(kw)
      if url
        urls << url
        print "."
      else
        print "x"
      end
      $stdout.flush
      sleep 0.1
    end

    puts "\n\nDone — #{urls.size}/#{keywords.size} URLs fetched.\n\n"
    puts "Paste this into db/seeds.rb as SEED_PHOTO_URLS:\n\n"
    puts "SEED_PHOTO_URLS = ["
    urls.each { |u| puts "  \"#{u}\"," }
    puts "].freeze"
  end
end
