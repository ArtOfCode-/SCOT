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

    get 'requests', to: 'rescue_requests#index', as: :global_requests
    scope ':disaster_id' do
      scope 'requests' do
        root to: 'rescue_requests#disaster_index', as: :disaster_requests
        get 'new', to: 'rescue_requests#new', as: :new_disaster_request
        post 'new', to: 'rescue_requests#create', as: :create_disaster_request
        post 'update', to: 'rescue_requests#update', as: :update_disaster_request
        get ':num', to: 'rescue_requests#show', as: :disaster_request
        get ':num/status', to: 'rescue_requests#triage_status', as: :request_triage_status
        post ':num/status', to: 'rescue_requests#apply_triage_status', as: :request_apply_status
        post ':num/safe', to: 'rescue_requests#mark_safe', as: :request_rescue_safe
      end
    end
  end

  scope '/requests' do
    root to: 'rescue_requests#new', as: :rescue_requests
    post 'create', to: 'rescue_requests#create', as: :request_create
    post 'update', to: 'rescue_requests#update_short', as: :request_update
    post 'submit', to: 'rescue_requests#update_long', as: :request_submit
  end

  scope '/api' do
    scope 'requests' do
      get 'geojson', to: 'api#geojson', as: :api_geojson
      get 'csv', to: 'api#csv', as: :api_csv
    end
  end
end
