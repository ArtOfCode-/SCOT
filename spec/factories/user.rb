FactoryGirl.define do

  factory :user do
    email 'test@test.com'
    password 'test_pass'
    password_confirmation 'test_pass'
    username 'tester'
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