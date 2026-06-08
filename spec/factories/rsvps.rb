FactoryBot.define do
  factory :rsvp do
    status { "going" }
    association :user
    association :post
  end
end
