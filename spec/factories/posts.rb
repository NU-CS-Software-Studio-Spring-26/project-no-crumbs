FactoryBot.define do
  factory :post do
    title { "Test Meal" }
    meal_date { 1.day.from_now }
    association :user
  end
end
