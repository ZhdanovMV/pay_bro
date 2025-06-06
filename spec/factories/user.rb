FactoryBot.define do
  sequence :email do |n|
    "user#{n}@example.com"
  end

  factory :user do
    email
    password { "password123" }

    after(:create) do |user|
      create(:account, user:)
    end
  end
end
