FactoryBot.define do
  factory :post do
    title { "Test Meal" }
    association :user
  end
end
