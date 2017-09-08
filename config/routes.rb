Rails.application.routes.draw do
  devise_for :users

  root to: 'disasters#index', as: :root

  scope '/admin' do
    scope '/roles' do
      root to: 'roles#index', as: :admin_roles
      post 'add', to: 'roles#add_role', as: :admin_add_role
      post 'remove', to: 'roles#remove_role', as: :admin_remove_role
    end
  end

  scope '/disasters' do
    root to: 'disasters#index', as: :disasters
    get 'new', to: 'disasters#new', as: :new_disaster
    post 'new', to: 'disasters#create', as: :create_disaster
  end
end
