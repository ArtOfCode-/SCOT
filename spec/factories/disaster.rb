FactoryGirl.define do

  factory :disaster do
    name 'test'
    description 'this is a test'

    trait :is_active do
      active true
    end

    trait :is_not_active do
      active false
    end
  end

end