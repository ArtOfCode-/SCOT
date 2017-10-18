FactoryGirl.define do

  factory :admin_role, class: Role do
    name 'admin'
    association :users, factory: :admin_user
  end

  factory :dev_role, class: Role do
    name 'developer'
    association :users, factory: :dev_user
  end

  factory :triage_role, class: Role do
    name 'triage'
    association :users, factory: :triage_user
  end

  factory :rescue_role, class: Role do
    name 'rescue'
    association :users, factory: :rescue_user
  end

  factory :medical_role, class: Role do
    name 'medical'
    association :users, factory: :medical_user
  end

  factory :broadcast_role, class: Role do
    name 'broadcast'
    association :users, factory: :broadcast_user
  end

  factory :miner_role, class: Role do
    name 'miner'
    association :users, factory: :miner_user
  end
end