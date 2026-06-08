FactoryBot.define do
  factory :community do
    sequence(:name) { |n| "Community #{n}" }
    description { "A great place to share meals." }
    creator { association :user }
  end
end
