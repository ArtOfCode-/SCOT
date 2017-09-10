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

  scope '/requests' do
    root to: 'rescue_requests#new', as: :rescue_requests
    post 'create', to: 'rescue_requests#create', as: :request_create
    post 'update', to: 'rescue_requests#update_short', as: :request_update
    post 'submit', to: 'rescue_requests#update_long', as: :request_submit
  end
end
