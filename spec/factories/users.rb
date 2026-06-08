FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    sequence(:username) { |n| "user#{n}" }
    password { "password123" }

    trait :google do
      provider { "google_oauth2" }
      sequence(:uid) { |n| "google-uid-#{n}" }
    end
  end
end
