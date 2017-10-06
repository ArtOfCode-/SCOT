FactoryGirl.define do

  factory :admin_role, class: Role do
    name 'admin'
    association :users, factory: :admin_user
  end
end