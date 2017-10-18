FactoryGirl.define do

  factory :user do
    email 'test@test.com'
    password 'test_pass'
    password_confirmation 'test_pass'
    username 'tester'

    trait :developer do
      association :roles, factory: :dev_role
    end

    trait :triage do
      association :roles, factory: :triage_role
    end

    trait :rescue do
      association :roles, factory: :rescue_role
    end

    trait :medical do
      association :roles, factory: :medical_role
    end

    trait :broadcaster do
      association :roles, factory: :broadcast_role
    end

    trait :miner do
      association :roles, factory: :miner_role
    end
  end

  factory :admin, class: User do
    email 'admin@admin.com'
    password 'test_pass'
    password_confirmation 'test_pass'
    username 'admin'
    # association :roles, :factory => :admin_role

    after(:create) do |admin|
      create_list(:admin_role, 1, users: [admin])
    end
  end
end