FactoryBot.define do
  factory :user do
    sequence(:google_id) { |n| "Id_#{n}" }
    sequence(:first_name) { |n| "User_#{n}" }
    last_name { "Name" }
    sequence(:email) { |n| "user_#{n}@email.com" }
    sequence(:token) { |n| "user_#{n}_token" }
  end
end