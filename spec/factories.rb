FactoryGirl.define do

  factory :user do
    email { Faker::Internet.email }
    login { Faker::Internet.user_name }
    password '12345678'
    password_confirmation { password }
    authentication_token { login }

    trait :developer do
      roles [:developer]
    end

    factory :developer, traits: [:developer]
  end

  factory :appliance_set do |f|
    name 'AS'
    user
  end

  factory :appliance_type do
    name { Faker::Lorem.words(10).join(' ') }
  end

  factory :security_proxy do |f|
    name 'security/proxy'
    payload { Faker::Lorem.words(10).join(' ') }
  end

  factory :security_policy do |f|
    name 'security/policy'
    payload { Faker::Lorem.words(10).join(' ') }
  end

  factory :appliance_configuration_template do |f|
    name { Faker::Lorem.words(10).join(' ') }
    appliance_type
  end
end